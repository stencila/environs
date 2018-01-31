{ nixpkgs, nixpkgsSrc }:

let
  stdenv = nixpkgs.stdenv; 

  runtime = nixpkgs.python;

  package = nixpkgs.pythonPackages.buildPythonPackage rec {
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
      rev = "add7ba1cdf2fc6910e0f10fac7055274969549c1";
      sha256 = "0l3b7hxqq21jb1sv6hlnksc15v9xh81rd0c144j4xcy6cjvx5m94";
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
