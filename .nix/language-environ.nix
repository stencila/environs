{ pkgs, langName, langRuntime, langPackages }:

let 
  
  json = pkgs.writeText "${langName}-environ.json" ''{
    "${langName}": {
        "id": ${langRuntime.name}
        "version": ${langRuntime.version},
        "packages": [${pkgs.lib.concatStringsSep "," (map (package: ''{
            "id": "${package.name or ""}",
            "name": "${package.pname or ""}"
            "version": "${package.version or ""}"
          }'') langPackages)}
        ]
    }
  }'';

  show = pkgs.writeScriptBin "${langName}-environ.show" ''
    cat ${json}
  '';

in {
  inherit json show;
}
