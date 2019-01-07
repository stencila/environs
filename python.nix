# Python environment

{ nixpkgs ? import <nixpkgs> {} }:

{
  # Python runtime
  python = nixpkgs.python37;

  # Python packages
  # Please add any new packages in alphabetical order
  inherit (nixpkgs.python37Packages)
    pandas
  ;
}