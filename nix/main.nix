{ nixpkgsFunc ? import nixpkgsSrc
, nixpkgsSrc ?
    (import <nixpkgs> {}).pkgs.fetchFromGitHub {
      # Release 18.03 (2018-04-04)
      owner = "NixOS"; repo = "nixpkgs";
      rev = "120b013e0c082d58a5712cde0a7371ae8b25a601";
      sha256 = "0hk4y2vkgm1qadpsm4b0q1vxq889jhxzjx3ragybrlwwg54mzp4f";
    }
, name
, envs
, fromImage ? null
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
    fromImage = fromImage;
  };

in 
  if nixpkgs.lib.inNixShell then shell else docker
