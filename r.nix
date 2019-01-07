# R environment

{ nixpkgs ? import <nixpkgs> {} }:

{
  # R runtime
  R = nixpkgs.R;

  # R packages
  # Please add any new packages in alphabetical order
  inherit (nixpkgs.rPackages)
    tidyverse
  ;
}
