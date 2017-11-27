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
    # R looks for packages in R_LIBS_USER which defaults to a location in the users HOME.
    # This causes issues when using `nix-shell` if the user has R installed. 
    # Here we define R_LIBS_USER so there is no clash. `/tmp` is used so that if the 
    # user installs any new R packages while in the Nix shell, they are not persisted. 
    shellHook = "export R_LIBS_USER=/tmp";
  };

in shell
