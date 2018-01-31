import ../../nix/main.nix {
  name = "stencila/mega";
  envs = [
    (import ./node/env.nix)
    (import ./py/env.nix)
    (import ./r/env.nix)
  ];
  fromImage = import ../core;
}
