{
  description = "Cardax ISPO Pool Metadata";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    flake-utils.url = github:numtide/flake-utils;
    cardax-ispo.url = git+ssh://git@github.com/CardaxDEX/ispo;
  };

  outputs = { nixpkgs, flake-utils, cardax-ispo, ... }:
    let
      nixpkgsFor = system: import nixpkgs {
        inherit system;
      };

      poolMetadataFor = system: cardax-ispo.pool-metadata;
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgsFor system;

          poolMetadata = poolMetadataFor system;

          fetchPoolMetadata = pkgs.writeShellScriptBin "fetch-pool-metadata" ''
            cp ${poolMetadata}/* .
            ${pkgs.git}/bin/git add *-metadata.json
            ${pkgs.git}/bin/git add *-metadata-hash.txt
            ${pkgs.git}/bin/git commit -m "Updated pool metadata."
          '';
        in
        {
          devShells = {
            "default" = pkgs.mkShell {
              buildInputs = [
                fetchPoolMetadata
              ];
            };
          };
        });
}
