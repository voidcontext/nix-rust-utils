{
  inputs.nixpkgs.url = "nixpkgs/release-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";
  inputs.crane.inputs.flake-utils.follows = "flake-utils";

  outputs = { self, crane, flake-utils, ... }@inputs:
    let
      mkLib = import ./lib { inherit crane; };
      versions = import ./packages/versions.nix;

      mkDefaultPkgs = system:
        import inputs.nixpkgs {
          inherit system;

          overlays = [ inputs.rust-overlay.overlays.default ];
        };

      mkRustToolchain = pkgs: pkgs.rust-bin.stable.latest.default;
      outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = mkDefaultPkgs system;
            checks = import ./checks { inherit pkgs mkLib; lib = mkLib { inherit pkgs crane rustToolchain; }; rootDir = ./.; };
            rustToolchain = (mkRustToolchain pkgs);
          in
          {
            inherit mkLib;
            inherit (checks) checks;

            testPackages = checks.testPackages;

            devShells.default = pkgs.mkShell {
              buildInputs = [
                pkgs.nixpkgs-fmt
                rustToolchain
                (versions { inherit pkgs rustToolchain; })
              ];
            };
          }
        );

      mkOutputs = selectMkCrateFn: system: args:
        let
          pkgs = mkDefaultPkgs system;
          lib = mkLib { inherit pkgs crane; rustToolchain = mkRustToolchain pkgs; };
          crate = (selectMkCrateFn lib) args;
        in
        {
          checks.default = crate.package;
          packages.default = crate.package;

          devShells.default = pkgs.mkShell {
            buildInputs = crate.nativeBuildInputs ++ crate.buildInputs ++ [
              crate.rustToolchain
              (versions { inherit pkgs; inherit (crate) rustToolchain; })
              pkgs.cargo-outdated
              pkgs.cargo-watch
              pkgs.cargo-bloat
              pkgs.cargo-udeps
              pkgs.rust-analyzer
              pkgs.rustfmt
              pkgs.nixpkgs-fmt
            ];
          };
        };
    in
    outputs // {
      lib.mkOutputs = args:
        flake-utils.lib.eachDefaultSystem (system:
          mkOutputs (lib: lib.mkCrate) system args
        );
      lib.mkWasmOutputs = args:
        flake-utils.lib.eachDefaultSystem (system:
          mkOutputs (lib: lib.mkWasmCrate) system args
        );
    };
}
