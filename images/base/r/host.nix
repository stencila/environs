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
    version = "0.28.2";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/r/";
      description = "Stencila for R";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/r";
      rev = "92d49b6d75117828a6fcbb3a665c8cf2d8176493";
      sha256 = "1pmqw2h01mhijr61qrq10gs95ibm4haqcq33sg0k0hdmrdv8731j";
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
      httpuv
      roxygen2
      RSQLite
      tidyverse
      urltools
    ]);
  };

  register = nixpkgs.writeScript "stencila-r-register" ''
    #!${stdenv.shell}
    Rscript -e 'stencila:::install()'
  '';

  run = nixpkgs.writeScript "stencila-r-run" ''
    #!${stdenv.shell}
    Rscript -e 'stencila:::run("0.0.0.0", 2000)'
  '';

in {
  inherit runtime package register run;
}
