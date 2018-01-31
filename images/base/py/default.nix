import ../../../nix/main.nix {
  name = "stencila/base/py";
  envs = [(import ./env.nix)];
}
