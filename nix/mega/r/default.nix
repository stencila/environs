import ../../../nix/main.nix {
  name = "stencila/mega-r";
  envs = [(import ./env.nix)];
  fromImage = import ../../core/r;
}
