{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv; 

  runtime = nixpkgs.python;

  pockets = nixpkgs.pythonPackages.buildPythonPackage rec {
    pname = "pockets";
    version = "0.6.2";
    meta = {
      homepage = "https://github.com/RobRuana/pockets";
      description = "Pockets full of useful Python tools!";
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/RobRuana/pockets";
      rev = "993947b968367a077ab2ab07d533effa0a65a539";
      sha256 = "1sfgbxm65av35sbbvmm67zsnxwdj2l15f4xck723slnd635p8x2k";
    };
    doCheck = false;

    propagatedBuildInputs = with nixpkgs.pythonPackages; [
      six
    ];
  };

  sphinxcontrib-napoleon = nixpkgs.pythonPackages.buildPythonPackage rec {
    pname = "sphinxcontrib-napoleon";
    version = "0.6.1";
    meta = {
      homepage = "https://github.com/sphinx-contrib/napoleon";
      description = "Marching toward legible docstrings";
    };

    src = nixpkgs.fetchgit {   
      url = "https://github.com/sphinx-contrib/napoleon";
      rev = "e267e986d8e6390557309035a544fcd3d8f8036e";
      sha256 = "0r9vzwmhrvc151vimvyzrwisal96lbkz1wv82drghwwk27xpfr9b";
    };
    doCheck = false;

    propagatedBuildInputs = with nixpkgs.pythonPackages; [
      six
      pockets
    ];
  };

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
      matplotlib
      numpy
      pandas
      pyjwt
      six
      sphinxcontrib-napoleon
      werkzeug
    ];
  };

  register = nixpkgs.writeScript "stencila-py-register" ''
    #!${stdenv.shell}
    python -c 'import stencila; stencila.register()'
  '';

  run = nixpkgs.writeScript "stencila-py-run" ''
    #!${stdenv.shell}
    python -c 'import stencila; stencila.run("0.0.0.0", 2000)'
  '';

in {
  inherit runtime package register run;
}
