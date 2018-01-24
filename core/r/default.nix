import ../../.nix/main.nix {
  name = "stencila/core/r";
  envs = [(import ./env.nix)];
  fromImage = import ../../base/r;
}
