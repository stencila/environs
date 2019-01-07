{ nixpkgs ? import ./nixpkgs.nix }:

import ./python.nix {} //
import ./node.nix {} //
import ./r.nix {} //
import ./terminal.nix {}
