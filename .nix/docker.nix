/*
Generate a Docker image for the environment
*/

{ nixpkgs, envs, name }:

let
  stdenv = nixpkgs.stdenv;
  dockerTools = nixpkgs.dockerTools;

  manifest = import ./manifest.nix { inherit nixpkgs envs; };
  register = import ./register.nix { inherit nixpkgs envs; };
  run = import ./run.nix { inherit nixpkgs envs; };

  cmd = nixpkgs.writeScriptBin "stencila-cmd" (''
    #!${stdenv.shell}
    export NODE_PATH=`for a in /nix/store/*/lib/node_modules; do echo $a; done | tr '\n' ':'`
    export PYTHONPATH=`for a in /nix/store/*/lib/python2.7/site-packages; do echo $a; done | tr '\n' ':'`
    export R_LIBS_SITE=`for a in /nix/store/*/library; do echo $a; done | tr '\n' ':'`
    ${register}/bin/stencila-register
    ${run}/bin/stencila-run
  '');

 inputs = with nixpkgs; [
      bash
      # Are the following necessary?
      curl
      pkgconfig
      gcc
      gfortran
      coreutils
      which
      sudo
      glibc.bin
    ]
      ++ [manifest register run cmd]
      ++ map (env: env.host.runtime) envs
      ++ map (env: env.host.package) envs
      ++ map (env: env.packages) envs;
  
  docker = dockerTools.buildImage {
    name = name;
    fromImage = null;
    contents = inputs;
    runAsRoot = ''
      #!${stdenv.shell}
      ${dockerTools.shadowSetup}
      mkdir -p /tmp
      chmod 777 /tmp
      groupadd --system stencila
      useradd --system --gid stencila --home-dir /stencila --no-create-home stencila
      mkdir -p /stencila
      chown stencila:stencila /stencila
      chmod 755 /stencila
    '';
    config = {
      Cmd = [ "${cmd}/bin/stencila-cmd" ];
      Env = [
        "TEMP=/tmp"
        "STENCILA_AUTHORIZATION=false"
      ];
      ExposedPorts = {
        "2000/tcp" = {};
      };
      User = "stencila";
    };
  };

in docker
