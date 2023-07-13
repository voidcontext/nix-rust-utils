{
  inputs.nixpkgs.url = "nixpkgs/release-23.05";
  inputs.nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";

  inputs.crane.url = "github:ipetkov/crane/v0.12.2";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";
  inputs.crane.inputs.flake-utils.follows = "flake-utils";

  inputs.advisory-db.url = "github:rustsec/advisory-db";
  inputs.advisory-db.flake = false;

  outputs = {
    self,
    crane,
    flake-utils,
    advisory-db,
    ...
  } @ inputs: let
    mkDefaultPkgs = system: nixpkgs:
      import nixpkgs {
        inherit system;

        overlays = [inputs.rust-overlay.overlays.default];
      };

    mkLib = import ./lib {inherit crane advisory-db;};

    outputs = flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = mkDefaultPkgs system inputs.nixpkgs;

        lib = mkLib {inherit pkgs;};

        checks = import ./checks {
          inherit pkgs lib mkLib;
          rootDir = ./.;
        };
      in {
        inherit checks lib;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.alejandra
          ];
        };
      }
    );
  in
    outputs
    // {
      inherit mkLib;
    };
}
