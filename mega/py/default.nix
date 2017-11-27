import ../../.nix/main.nix {
  name = "stencila/mega/py";
  envs = [(import ./env.nix)];
}
