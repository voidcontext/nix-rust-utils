{ inputs, ... }:

with builtins;
rec {
  mkPkgs = { system, nixpkgs ? inputs.nixpkgs, rust-overlay ? inputs.rust-overlay }:
    import nixpkgs {
      inherit system;

      overlays = [ rust-overlay.overlays.default ];
    };

  mkDefaultRustToolchain = { pkgs, ... }: pkgs.rust-bin.stable.latest.default;

  mkCrateFn = { pkgs, ... }:
    with pkgs.lib;
    let fromCargoToml = src: path: attrsets.getAttrFromPath path (fromTOML (readFile (src + "/Cargo.toml")));
    in
    { src
    , pname ? fromCargoToml src [ "package" "name" ]
    , version ? fromCargoToml src [ "package" "version" ]
    , rustToolchain ? mkDefaultRustToolchain { inherit pkgs; }
    }:
    let
      nativeBuildInputs = with pkgs.lib;
        (optional pkgs.stdenv.isLinux pkgs.pkg-config) ++ [ pkgs.cmake ];

      buildInputs = with pkgs.lib;
        (optional pkgs.stdenv.isLinux pkgs.openssl) ++
        (optional (pkgs.system == "x86_64-darwin")
          pkgs.darwin.apple_sdk.frameworks.Security);

      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;

      commonArgs = {
        src = craneLib.cleanCargoSource src;

        inherit buildInputs nativeBuildInputs;
      };

      deps = craneLib.buildDepsOnly (commonArgs // {
        inherit pname version;
      });

      package = craneLib.buildPackage {
        src = craneLib.cleanCargoSource src;
        inherit pname version;
        cargoArtifacts = deps;
        preCheck = ''
          cargo fmt --check
          cargo clippy  -- -W clippy::pedantic -A clippy::missing-errors-doc -A clippy::missing-panics-doc
        '';

        inherit buildInputs nativeBuildInputs;
      };

    in
    {
      inherit
        package
        rustToolchain
        buildInputs
        nativeBuildInputs;
    };

  versions = { pkgs, rustToolchain }: pkgs.writeShellScriptBin "versions" ''
    echo "nixpkgs: ${pkgs.lib.version}"
    ${rustToolchain}/bin/rustc --version
    ${rustToolchain}/bin/cargo --version
  '';

  mkOutputs = system: args:
    let
      pkgs = mkPkgs { inherit system; };
      mkCrate = mkCrateFn { inherit pkgs; };
      crate = mkCrate args;
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
}
