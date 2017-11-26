{
  name = "node";
  host = (import ../../base/node/host.nix);
  packages= (import ./packages.nix);
}
