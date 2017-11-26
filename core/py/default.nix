import ../../.nix/main.nix {
  name = "stencila-core-py";
  envs = [(import ./env.nix)];
}
