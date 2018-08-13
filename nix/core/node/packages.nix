{ nixpkgs }:

nixpkgs.lib.attrValues (import ./node2nix {
  pkgs = nixpkgs;
  inherit (nixpkgs) system nodejs;
})
