/*
Register the Stencila hosts so that they can discover each another within the environment
*/

{ nixpkgs, envs }:

let
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  
  register = nixpkgs.writeScriptBin "stencila-register" (''
    #!${stdenv.shell}
  '' + lib.concatMapStrings (env: ''
    ${env.host.register}
  '') envs);

in register
