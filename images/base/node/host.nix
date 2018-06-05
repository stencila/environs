{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv;

  runtime = nixpkgs.nodejs-8_x;

  rawNodePackages = import ./node2nix {
    pkgs = nixpkgs;
    inherit (nixpkgs) system nodejs;
  };
  nodePackages = rawNodePackages // {
    stencilaNode = rawNodePackages."stencila-node-0.28.15".overrideAttrs (oldAttrs: rec {
      pname = "stencila-node";
      buildInputs = (oldAttrs.buildInputs or []) ++ (with nixpkgs; [
        pkgconfig
        libjpeg
        giflib
        cairo
        rawNodePackages.node-pre-gyp
        rawNodePackages.node-gyp-build
        zeromq
      ]);
    });
  };
  package = nodePackages.stencilaNode;

  register = nixpkgs.writeScript "stencila-node-register" ''
    #!${stdenv.shell}
    node -e "require('stencila-node').register()"
  '';

  run = nixpkgs.writeScript "stencila-node-run" ''
    #!${stdenv.shell}
    ADDRESS=''${1:-"0.0.0.0"}
    PORT=''${2:-2000}
    TIMEOUT=''${4:-3600}
    node -e "require('stencila-node').run('{ \
      \"address\": \"$ADDRESS\", \
      \"port\": $PORT, \
      \"timeout\": $TIMEOUT \
    }')"
  '';

in {
  inherit runtime package register run;
}
