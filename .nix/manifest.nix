/*
Display a JSON manifest of the Stencila hosts and the packages installed within each
*/

{ nixpkgs, envs }:

let 
  lib = nixpkgs.lib;
  
  json = nixpkgs.writeText "manifest.json" ''{
    ${lib.concatStringsSep "," (map (env: ''
      "${env.name}": {
        "runtime": {
          "name": "${env.host.runtime.name}",
          "version": "${env.host.runtime.version or ""}",
          "id": "${lib.removePrefix "/nix/store/" env.host.runtime}"
        },
        "packages": [${lib.concatStringsSep "," (map (package: ''{
            "name": "${package.name or ""}",
            "package": "${package.pname or ""}",
            "version": "${package.version or ""}",
            "id": "${lib.removePrefix "/nix/store/" package}"
          }'') ([env.host.package] ++ env.packages) )}
        ]
      }'') envs )}
  }'';

  manifest = nixpkgs.writeScriptBin "stencila-manifest" ''
    cat ${json}
  '';

in manifest
