{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv; 

  runtime = nixpkgs.python;

  package = nixpkgs.pythonPackages.buildPythonPackage rec {
    pname = "stencila-py";
    version = "0.28.1";
    name = "${pname}-${version}";
    meta = {
      homepage = "https://github.com/stencila/py/";
      description = "Stencila for Python";
      license = stdenv.lib.licenses.apsl20;
      maintainers = with stdenv.lib.maintainers; [ nokome ];
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/stencila/py";
      rev = "933e01f5352ad3d8857955f82eec9d3c48e9731f";
      sha256 = "19yk1270jk40q5nd386nhlxvlna3k8ay39ldyswq31yzvbxiijhp";
    };

    propagatedBuildInputs = with nixpkgs.pythonPackages; [
      six
      numpy
      pandas
      matplotlib
      werkzeug
    ];
  };

  register = nixpkgs.writeScript "stencila-py-register" ''
    #!${stdenv.shell}
    python -c 'import stencila; stencila.install()'
  '';

  run = nixpkgs.writeScript "stencila-py-run" ''
    #!${stdenv.shell}
    python -c 'import stencila; stencila.run("0.0.0.0", 2000)'
  '';

in {
  inherit runtime package register run;
}
