{
  name = "py";
  host = (import ../../base/py/host.nix);
  packages= (import ./packages.nix);
}
