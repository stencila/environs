/*
Run the primary Stencila host (the first within the list of sub-environments)
*/

{ nixpkgs, envs }:

let
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  
  run = nixpkgs.writeScriptBin "stencila-run" (''
    #!${stdenv.shell}
    ${(builtins.head envs).host.run} "$@"
  '');

in run
