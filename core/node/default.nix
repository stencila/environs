import ../../.nix/main.nix {
  name = "stencila-core-node";
  envs = [(import ./env.nix)];
}
