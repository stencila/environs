{ nixpkgs
, nixpkgsSrc
}:
let
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  # Read the generated node packages
  rawNodePackages = import ./node2nix {
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

in {
  name = "node";
  runtime = nixpkgs.nodejs;
  packages = import ./packages.nix { inherit nodePackages; };
  stencila-package = nodePackages.stencila-node;
  stencila-install = ''
    node -e 'require("stencila-node").install()'
  '';
  stencila-run = nixpkgs.writeScriptBin "stencila-run" ''
    node -e 'require("stencila-node").run("0.0.0.0", 2000)'
  '';
}