{ nixpkgs
, nixpkgsSrc
}:
let
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;

  python-packages = [stencila-py] ++ lib.filter (p: p != null) (import ./packages.nix {
    pythonPackages = nixpkgs.pythonPackages;
  });

  stencila-py = nixpkgs.pythonPackages.buildPythonPackage rec {
    pname = "stencila-py";
    version = "0.28.0";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/py/";
      description = "Stencila for Python";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/py";
      rev = "9f3a33aca80100c51fcec6e58f537113b1c5511b";
      sha256 = "0f2jaddvrpkkmf6abnnbybjlwiggjkqg0fi0kwhak2pbx0d3fkrb";
    };

    propagatedBuildInputs = with nixpkgs.pythonPackages; [
      six
      numpy
      pandas
      matplotlib
      werkzeug
    ];
  };

in {
  name = "python";
  runtime = nixpkgs.python;
  packages = python-packages;
  stencila-package = stencila-py;
  stencila-install = ''
    python -c 'import stencila; stencila.install()'
  '';
}