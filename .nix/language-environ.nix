{ nixpkgs, languages }:

let 
  
  json = nixpkgs.writeText "language-environ.json" ''{
    ${nixpkgs.lib.concatStringsSep "," (map (lang: ''
      "${lang.name}": {
        "id": "${lang.runtime.name}",
        "version": "${lang.runtime.version or ""}",
        "packages": [${nixpkgs.lib.concatStringsSep "," (map (package: ''{
            "id": "${package.name or ""}",
            "name": "${package.pname or ""}",
            "version": "${package.version or ""}"
          }'') lang.packages)}
        ]
      }'') languages)}
  }'';

  show = nixpkgs.writeScriptBin "language-environ.show" ''
    cat ${json}
  '';

in {
  inherit json show;
}
