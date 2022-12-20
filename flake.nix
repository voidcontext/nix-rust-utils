{
  inputs.nixpkgs.url = "nixpkgs/release-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";

  inputs.nil.url = "github:oxalica/nil?ref=2022-12-01";

  outputs = { self, nil, flake-utils, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
      outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = lib.mkPkgs { inherit system; };
            defaultRustToolchain = lib.mkDefaultRustToolchain { inherit pkgs; };
            checks = import ./checks { inherit pkgs lib; };
          in
          {
            inherit lib;
            inherit (checks) checks;

            apps.check-builds = {
              "type" = "app";
              "program" = "${checks.scripts.check-builds}/bin/check-builds";
            };

            testPackages = checks.testPackages;

            devShells.default = pkgs.mkShell {
              buildInputs = [
                pkgs.nixpkgs-fmt
                defaultRustToolchain
                (lib.versions { inherit pkgs; rustToolchain = defaultRustToolchain; })
                nil.packages.${system}.default
              ];
            };
          }
        );
    in
    outputs // {
      lib.mkOutputs = args:
        flake-utils.lib.eachDefaultSystem (system: lib.mkOutputs system args);
    };
}
