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
