{ nixpkgsFunc ? import nixpkgsSrc
, nixpkgsSrc ?
    (import <nixpkgs> {}).pkgs.fetchFromGitHub {
      owner = "hamishmack"; repo = "nixpkgs";
      rev = "d65e439ffffbda9619c8538823fe79230fcd850a";
      sha256 = "1vrak85b14jn7qk9cspwv0kg3qkpqpbsxdrxspc980pksg475scr";
    }
    # To pic up nixpkgs from a local source use
    # builtins.filterSource (path: type: !(builtins.any (x: x == baseNameOf path) [".git"])) ./nixpkgs
, includeR            ? true
, includePython       ? true
, nodePackageSelect   ? import ./node/packages.nix
, rPackageSelect      ? import ./packages-r.nix
, pythonPackageSelect ? import ./packages-python.nix
, name                ? "stencila-docker" # The name of the docker image
, fromImage           ? null              # A base image from which to build a layered docker image
}:
let
  nixpkgs = nixpkgsFunc {
    system = builtins.currentSystem;
    config = {
      packageOverrides = pkgs: {
        nodejs = pkgs."nodejs-6_x";
      };
    };
  };
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  # Read the generated node packages
  rawNodePackages = import ./node {
    pkgs = nixpkgs;
    inherit (nixpkgs) system nodejs;
  };
  nodePackages = rawNodePackages // {
    stencila-node = rawNodePackages."stencila-node-0.28.1".overrideAttrs (oldAttrs: rec {
      buildInputs = (oldAttrs.buildInputs or []) ++ (with nixpkgs; [
        pkgconfig
        libjpeg
        giflib
        cairo
        rawNodePackages.node-pre-gyp
        rawNodePackages.node-gyp-build
      ]);
    });
  };
  nodePackageList = nodePackageSelect { inherit nodePackages; };
  rPackageList = if includeR then [stencila-r] ++ rPackageSelect { inherit (nixpkgs) rPackages; } else [];
  pythonPackageList = if includePython then [stencila-py] ++ lib.filter (p: p != null) (pythonPackageSelect { inherit (nixpkgs) pythonPackages; }) else [];
  stencila-py = nixpkgs.pythonPackages.buildPythonPackage rec {
    pname = "stencila-py";
    version = "0.28.0";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/py/";
      description = "Stencila for Python";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/py";
      rev = "9f3a33aca80100c51fcec6e58f537113b1c5511b";
      sha256 = "0f2jaddvrpkkmf6abnnbybjlwiggjkqg0fi0kwhak2pbx0d3fkrb";
    };

    propagatedBuildInputs = with nixpkgs.pythonPackages; [
      six
      numpy
      pandas
      matplotlib
      werkzeug
    ];
  };
  buildRPackage = nixpkgs.callPackage "${nixpkgsSrc}/pkgs/development/r-modules/generic-builder.nix" {
    inherit (nixpkgs.darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (nixpkgs) R gettext gfortran;
  };
  stencila-r = buildRPackage rec {
    pname = "stencila-r";
    version = "0.28.0";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/r/";
      description = "Stencila for R";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/r";
      rev = "c51026b768f29526f9129454bafc5feebd4d48f0";
      sha256 = "1cg6xdsgv2hd2lb20amix4nmz99i7750nb5i83k4137da20kvlyn";
    };

    buildInputs = with nixpkgs; [
      R
    ] ++ (with rPackages; [
      devtools
      base64enc
      DBI
      evaluate
      httpuv
      RSQLite
      tidyverse
      urltools
    ]);
  };
  stencila-docker-run = nixpkgs.writeScriptBin "stencila-docker-run" ''
    #!${stdenv.shell}
    # TODO figure out how to better include transitive deps
    # export NODE_PATH=${nixpkgs.lib.concatStringsSep ":" (map (p: p + "/lib/node_modules") nodePackageList)}
    # export PYTHONPATH=${nixpkgs.lib.concatStringsSep ":" (map (p: p + "/lib/python2.7/site-packages") pythonPackageList)}
    # export R_LIBS_SITE=${nixpkgs.lib.concatStringsSep ":" (map (p: p + "/library") rPackageList)}
    export NODE_PATH=`ls -d /nix/store/*/lib/node_modules | tr '\n' ':'`
    export PYTHONPATH=`ls -d /nix/store/*/lib/python2.7/site-packages | tr '\n' ':'`
    export R_LIBS_SITE=`ls -d /nix/store/*/library | tr '\n' ':'`
    ${stencila-install}/bin/stencila-install
    ${stencila-run}/bin/stencila-run
  '';
  stencila-install = nixpkgs.writeScriptBin "stencila-install" (''
    #!${stdenv.shell}
    echo Install stencila node
    node -e 'require("stencila-node").install()'
  '' + (
    lib.optionalString includePython ''
        echo Install stencila python
        python -c 'import stencila; stencila.install()'
      ''
  ) + (
    lib.optionalString includeR ''
        echo Install stencila R
        Rscript -e 'stencila:::install()'
      ''
  ));
  stencila-run = nixpkgs.writeScriptBin "stencila-run" ''
    node -e 'require("stencila-node").run("0.0.0.0", 2000)'
  '';
  environJson = nixpkgs.writeText "environ.json" ''
    {
      "node": {
        "system": "${stdenv.system}",
        "version": "${nodePackages.stencila-node.version}",
        "nixPath": "${nodePackages.stencila-node}",
        "packages": [${lib.concatStringsSep "," (map (p: ''
          {
            "name": "${p.name}",
            "system": "${p.system}",
            "nixPath": "${p}"
          }'') nodePackageList)}]
      },
      "python": ${
        if includePython
          then ''
            {
              "system": "${stdenv.system}",
              "version": "${stencila-py.version}",
              "nixPath": "${stencila-py}",
              "packages": [${lib.concatStringsSep "," (map (p: ''
                {
                  "name": "${p.name}",
                  "system": "${p.system}",
                  "nixPath": "${p}"
                }'') pythonPackageList)}]
            },
          ''
          else ''null,''
        }
      "r": ${
        if includeR
          then ''
            {
              "system": "${stdenv.system}",
              "version": "${stencila-r.version}",
              "nixPath": "${stencila-r}",
              "packages": [${lib.concatStringsSep "," (map (p: ''
                {
                  "name": "${p.name}",
                  "system": "${p.system}",
                  "nixPath": "${p}"
                }'') rPackageList)}]
            }
          ''
          else ''null''
        }
    }
  '';
  stencila-depends = with nixpkgs; [
      curl
      pkgconfig
      gcc
      gfortran
      jq
      cairo
      nodejs
      coreutils
      bash
      which
      sudo
      glibc.bin
    ] ++ lib.optionals includePython [ python ] ++ lib.optionals includeR [ R ];
  stencila-core = stdenv.mkDerivation {
    name = "stencila-core";
    version = "1";
    src = if nixpkgs.lib.inNixShell then null else nixpkgs.nix;
    buildCommand = ''
      mkdir -p $out/stencila
      jq . ${environJson} > $out/stencila/.environ.json
      cat $out/stencila/.environ.json
    '';
    passAsFile = ["buildCommand"];
    buildInputs = [stencila-docker-run nixpkgs.jq];
  };
  stencila-shell = stdenv.mkDerivation {
    name = "stencila-shell";
    version = "1";
    buildInputs = [stencila-install stencila-run]
      ++ stencila-depends
      ++ nodePackageList
      ++ pythonPackageList
      ++ rPackageList;
  };
  stencila-docker = nixpkgs.dockerTools.buildImage {
    inherit name fromImage;
    contents = [stencila-core] ++ stencila-depends;
    runAsRoot = ''
      #!${stdenv.shell}
      ${nixpkgs.dockerTools.shadowSetup}
      mkdir -p /tmp
      chmod 777 /tmp
      groupadd --system stencila
      useradd --system --gid stencila --home-dir /stencila --no-create-home stencila
      mkdir -p /stencila
      chown stencila:stencila /stencila
      chmod 755 /stencila
      jq . ${environJson} > /stencila/.environ.json
      chown stencila:stencila /stencila/.environ.json
    '';
    config = {
      Cmd = [ "${stencila-docker-run}/bin/stencila-docker-run" ];
      Env = [
        "TEMP=/tmp"
        "STENCILA_AUTHORIZATION=false"
      ];
      ExposedPorts = {
        "2000/tcp" = {};
      };
      User = "stencila";
    };
  };

in
  if nixpkgs.lib.inNixShell
    then stencila-shell
    else stencila-docker
