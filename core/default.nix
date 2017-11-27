import ../.nix/main.nix {
  name = "stencila/core";
  envs = [
    (import ./node/env.nix)
    (import ./py/env.nix)
    (import ./r/env.nix)
  ];
}
