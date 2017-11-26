import ../../.nix/main.nix {
  name = "stencila-base-r";
  envs = [(import ./env.nix)];
}
