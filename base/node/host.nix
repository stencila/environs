{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv;

  runtime = nixpkgs.nodejs;

  rawNodePackages = import ./node2nix {
    pkgs = nixpkgs;
    inherit (nixpkgs) system nodejs;
  };
  nodePackages = rawNodePackages // {
    stencilaNode = rawNodePackages."stencila-node-0.28.1".overrideAttrs (oldAttrs: rec {
      pname = "stencila-node";
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
  package = nodePackages.stencilaNode;

  register = nixpkgs.writeScript "stencila-node-register" ''
    #!${stdenv.shell}
    node -e 'require("stencila-node").install()'
  '';

  run = nixpkgs.writeScript "stencila-node-run" ''
    #!${stdenv.shell}
    node -e 'require("stencila-node").run("0.0.0.0", 2000)'
  '';

in {
  inherit runtime package register run;
}
