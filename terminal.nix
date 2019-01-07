# Terminal environment
#
# Defines Nix packages available within a terminal/console/shell environment.
# We use the name "terminal" because "shell.nix" has special meaning in Nix
# tooling (https://stackoverflow.com/a/44621588)

{ nixpkgs ? import <nixpkgs> {} }:

{
  inherit (nixpkgs)
    bashInteractive
    cacert
    coreutils
    findutils
    gnugrep
    openssl
    utillinux
    which
  ;
}
