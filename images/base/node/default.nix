import ../../../nix/main.nix {
  name = "stencila/base/node";
  envs = [(import ./env.nix)];
}
