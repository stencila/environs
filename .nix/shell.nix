{ nixpkgs, envs }:

let

  manifest = import ./manifest.nix { inherit nixpkgs envs; };
  register = import ./register.nix { inherit nixpkgs envs; };
  run = import ./run.nix { inherit nixpkgs envs; };

  inputs = [manifest register run]
      ++ map (env: env.host.runtime) envs
      ++ map (env: env.host.package) envs
      ++ map (env: env.packages) envs;
  
  shell = nixpkgs.stdenv.mkDerivation {
    name = "stencila-shell";
    version = "1";
    buildCommand = "mkdir -p $out/stencila";
    buildInputs = inputs;
  };

in shell
