{
  inputs.nixpkgs.url = "nixpkgs/release-22.11";
  inputs.nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";
  inputs.crane.inputs.flake-utils.follows = "flake-utils";

  outputs = {
    self,
    crane,
    flake-utils,
    ...
  } @ inputs: let
    mkLib = import ./lib {inherit crane;};
    versions = import ./packages/versions.nix;

    mkDefaultPkgs = system: nixpkgs:
      import nixpkgs {
        inherit system;

        overlays = [inputs.rust-overlay.overlays.default];
      };

    mkRustToolchain = pkgs: pkgs.rust-bin.stable.latest.default;

    outputs = flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = mkDefaultPkgs system inputs.nixpkgs;
        pkgsUnstable = mkDefaultPkgs system inputs.nixpkgs-unstable;
        rustToolchain = mkRustToolchain pkgs;
        lib = mkLib {inherit pkgs pkgsUnstable rustToolchain;};

        checks = import ./checks {
          inherit pkgs lib mkLib;
          rootDir = ./.;
        };
      in {
        inherit checks lib;

        env = {inherit pkgs rustToolchain;};

        testPackages = checks.testPackages;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.alejandra
            rustToolchain
            (versions {inherit pkgs pkgsUnstable rustToolchain;})
          ];
        };
      }
    );

    mkOutputs = selectMkCrateFn: system: mkArgs: let
      pkgs = mkDefaultPkgs system inputs.nixpkgs;
      pkgsUnstable = mkDefaultPkgs system inputs.nixpkgs-unstable;
      rustToolchain = mkRustToolchain pkgs;
      lib = mkLib {
        inherit pkgs crane rustToolchain;
      };
      crate = (selectMkCrateFn lib) (mkArgs {
        inherit pkgs pkgsUnstable rustToolchain;
        nruLib = lib;
      });
    in {
      checks.default = crate.package;
      packages.default = crate.package;

      devShells.default = (lib.mkDevShell crate);
    };
  in
    outputs
    // {
      inherit mkLib;

      lib =
        outputs.lib
        // {
          mkOutputs = mkArgs:
            flake-utils.lib.eachDefaultSystem (
              system:
                mkOutputs (lib: lib.mkCrate) system mkArgs
            );
          mkWasmOutputs = mkArgs:
            flake-utils.lib.eachDefaultSystem (
              system:
                mkOutputs (lib: lib.mkWasmCrate) system mkArgs
            );
        };
    };
}
