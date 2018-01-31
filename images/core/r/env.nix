{
  name = "r";
  host = (import ../../base/r/host.nix);
  packages= (import ./packages.nix);
}
