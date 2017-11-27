import ../../.nix/main.nix {
  name = "stencila/mega/node";
  envs = [(import ./env.nix)];
  fromImage = import ../../core/node;
}
