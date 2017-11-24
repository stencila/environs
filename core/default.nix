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
, languageFuncs ? [
      (import ./node/language.nix)
    ]
    ++ (if includeR      then [(import ./r/language.nix )] else [])
    ++ (if includePython then [(import ./py/language.nix)] else [])
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
  languages = map (f: f { inherit nixpkgs nixpkgsSrc; }) languageFuncs;
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  stencila-docker-run = nixpkgs.writeScriptBin "stencila-docker-run" (''
    #!${stdenv.shell}
  '' + (lib.concatMapStrings (lang: lib.concatMapStrings (p:
  		"# Using " + p + "\n") lang.packages) languages) + ''
    export NODE_PATH=`for a in /nix/store/*/lib/node_modules; do echo $a; done | tr '\n' ':'`
    export PYTHONPATH=`for a in /nix/store/*/lib/python2.7/site-packages; do echo $a; done | tr '\n' ':'`
    export R_LIBS_SITE=`for a in /nix/store/*/library; do echo $a; done | tr '\n' ':'`
    ${stencila-install}/bin/stencila-install
    ${(builtins.head languages).stencila-run}/bin/stencila-run
  '');
  stencila-install = nixpkgs.writeScriptBin "stencila-install" (''
    #!${stdenv.shell}
  '' + lib.concatMapStrings (lang: ''
      echo Install stencila ${lang.name}
    '' + lang.stencila-install) languages);
  stencila-run = (builtins.head languages).stencila-run;
  environJson = (import ../.nix/language-environ.nix { inherit nixpkgs languages; }).json;
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
    ] ++ map (lang: lang.runtime) languages;
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
      ++ map (lang: lang.packages) languages;
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
