{
  inputs.nixpkgs.url = "nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.flake-utils.follows = "flake-utils";

  inputs.advisory-db.url = "github:rustsec/advisory-db";
  inputs.advisory-db.flake = false;

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = {
    nixpkgs,
    crane,
    flake-utils,
    advisory-db,
    ...
  } @ inputs: let
    mkLib = import ./lib {inherit crane advisory-db;};

    outputs = flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        lib = mkLib {inherit pkgs;};

        checks = import ./checks {
          inherit nixpkgs system lib mkLib;
          inherit (inputs) rust-overlay;
          rootDir = ./.;
        };
      in {
        inherit checks lib;

        packages.checks = pkgs.symlinkJoin {
          name = "nix-rust-utils-checks";
          paths = builtins.attrValues checks;
        };

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
