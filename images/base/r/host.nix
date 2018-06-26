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
      rev = "4ebd3a8106294060316574eb340c7108542f722a";
      sha256 = "1xzjqpcc89xy6zysh0l6hi5hw9h9vpkzqlmmprd53ah1sjrfnsdl";
    };

    buildInputs = [];

    propagatedBuildInputs = with nixpkgs; [
      R
      which
    ] ++ (with rPackages; [
      base64enc
      CodeDepends
      DBI
      devtools
      evaluate
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
