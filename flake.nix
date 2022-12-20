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
      outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            overlays = [ inputs.rust-overlay.overlays.default ];

            pkgs = import inputs.nixpkgs { inherit system overlays; };

            defaultRustToolchain = pkgs.rust-bin.stable.latest.default;

            versions = rustToolchain: pkgs.writeShellScriptBin "versions" ''
              echo "nixpkgs: ${pkgs.lib.version}"
              ${rustToolchain}/bin/rustc --version
              ${rustToolchain}/bin/cargo --version
            '';

            callPackage = pkgs.lib.callPackageWith {
              nil = nil.packages.${system}.default;
              inherit pkgs flake-utils defaultRustToolchain versions;
            };

            lib = callPackage ./lib { inherit (inputs) crane rust-overlay; };

            checks = callPackage ./checks { inherit lib; };
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
                (versions defaultRustToolchain)
                nil.packages.${system}.default
              ];
            };
          }
        );
    in
    outputs // {
      lib.mkOutputs = args:
        flake-utils.lib.eachDefaultSystem (system: outputs.lib.${system}.mkOutputs args);
    };
}
