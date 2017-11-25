{ nixpkgs
, nixpkgsSrc
}:
let
  stdenv = nixpkgs.stdenv;
  rPackageList = [stencila-r] ++ import ./packages.nix { inherit (nixpkgs) rPackages; };
  buildRPackage = nixpkgs.callPackage "${nixpkgsSrc}/pkgs/development/r-modules/generic-builder.nix" {
    inherit (nixpkgs.darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (nixpkgs) R gettext gfortran;
  };
  stencila-r = buildRPackage rec {
    pname = "stencila-r";
    version = "0.28.0";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/r/";
      description = "Stencila for R";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/r";
      rev = "c51026b768f29526f9129454bafc5feebd4d48f0";
      sha256 = "1cg6xdsgv2hd2lb20amix4nmz99i7750nb5i83k4137da20kvlyn";
    };

    buildInputs = with nixpkgs; [
      R
    ] ++ (with rPackages; [
      devtools
      base64enc
      DBI
      evaluate
      httpuv
      RSQLite
      tidyverse
      urltools
    ]);
  };
in {
  name = "R";
  runtime = nixpkgs.R;
  packages = rPackageList;
  stencila-package = stencila-r;
  stencila-install = ''
    Rscript -e 'stencila:::install()'
  '';
}

