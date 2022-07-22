{
  inputs.nixpkgs.url = "nixpkgs/release-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";


  outputs = { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ inputs.rust-overlay.overlays.default ];

        pkgs = import inputs.nixpkgs { inherit system overlays; };

        rust = import ./rust;

        checks = import ./checks pkgs system rust;
      in
      {
        inherit rust;
        inherit (checks) checks;

        apps.check-scripts = {
          "type" = "app";
          "program" = "${checks.scripts.check-builds-failing}/bin/check-builds-failing";
        };

        testPackages = checks.testPackages;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt ];
        };
      }
    );
}
