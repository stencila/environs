{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv;

  runtime = nixpkgs.R;

  buildRPackage = nixpkgs.callPackage "${nixpkgsSrc}/pkgs/development/r-modules/generic-builder.nix" {
    inherit (nixpkgs.darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (nixpkgs) R gettext gfortran;
  };
  package = buildRPackage rec {
    pname = "stencila-r";
    version = "0.28.3";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/r/";
      description = "Stencila for R";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/r";
      rev = "11dde7e405777fab3f640c9796a59763f53e0c0f";
      sha256 = "0k6lxhsfwzydwigbssggym7mffa0i8vr26k0ak91p9k8vsvwk7ij";
    };

    buildInputs = [];

    propagatedBuildInputs = with nixpkgs; [
      R
      which
    ] ++ (with rPackages; [
      devtools
      base64enc
      DBI
      evaluate
      globals
      httpuv
      jose
      roxygen2
      RSQLite
      urltools
      uuid
    ]);
  };

  register = nixpkgs.writeScript "stencila-r-register" ''
    #!${stdenv.shell}
    Rscript -e 'stencila::register()'
  '';

  run = nixpkgs.writeScript "stencila-r-run" ''
    #!${stdenv.shell}
    Rscript -e 'stencila::run("0.0.0.0", 2000)'
  '';

in {
  inherit runtime package register run;
}
