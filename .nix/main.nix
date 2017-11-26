{ nixpkgsFunc ? import nixpkgsSrc
, nixpkgsSrc ?
    (import <nixpkgs> {}).pkgs.fetchFromGitHub {
      owner = "hamishmack"; repo = "nixpkgs";
      rev = "d65e439ffffbda9619c8538823fe79230fcd850a";
      sha256 = "1vrak85b14jn7qk9cspwv0kg3qkpqpbsxdrxspc980pksg475scr";
    }
, name
, envs
}:

let
  nixpkgs = nixpkgsFunc {
    system = builtins.currentSystem;
  };

  # Call `env.host` and `env.packages` functions for each  `env` to generate
  # environment sets to pass to  `shell` and `docker`
  envSets = map (env: {
    name = env.name;
    host = env.host { inherit nixpkgs nixpkgsSrc; };
    packages = if env.packages != null then env.packages { inherit nixpkgs; } else [];
  }) envs;

  # Derivations for a Nix shell and Docker image
  shell = import ./shell.nix {
    nixpkgs = nixpkgs;
    envs = envSets;
  };
  docker = import ./docker.nix {
    nixpkgs = nixpkgs;
    envs = envSets;
    name = name;
  };

in 
  if nixpkgs.lib.inNixShell then shell else docker
