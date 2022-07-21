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
      in {
        inherit rust;

        checks."rust.buildRustPackage" =
          rust.buildRustPackage pkgs { src = ./checks/rust/package; };
      }
    );
}
