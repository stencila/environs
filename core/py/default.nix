{ nixpkgsFunc ? import nixpkgsSrc
, nixpkgsSrc ?
    (import <nixpkgs> {}).pkgs.fetchFromGitHub {
      owner = "hamishmack"; repo = "nixpkgs";
      rev = "d65e439ffffbda9619c8538823fe79230fcd850a";
      sha256 = "1vrak85b14jn7qk9cspwv0kg3qkpqpbsxdrxspc980pksg475scr";
    }
}:
let
  nixpkgs = nixpkgsFunc {
    system = builtins.currentSystem;
  };
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;

  python-packages = [] ++ lib.filter (p: p != null) (import ./packages.nix {
    pythonPackages = nixpkgs.pythonPackages;
  });

  python-environ = import ../../.nix/language-environ.nix {
    pkgs = nixpkgs;
    langName = "python";
    langRuntime = nixpkgs.python;
    langPackages = python-packages;
  };

in

python-environ.show
