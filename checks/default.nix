{
  pkgs,
  mkLib,
  lib,
  rootDir,
  ...
}: let
  cargoBin = "${pkgs.rust-bin.stable.latest.default}/bin/cargo";
  cargoWrapper = pkgs.writeShellScriptBin "cargo" ''
    mkdir -p $out
    touch $out/cargo.log

    echo "cargo $@" >> $out/cargo.log

    ${cargoBin} $@
  '';

  # test scenarios

  # can build rust package
  checks.can-build-rust-package = (lib.mkCrate {src = ./rust/hello-world;}).package;
  # can build rust wasm package
  checks.can-build-rust-wasm-package = (lib.mkWasmCrate {src = ./rust/wasm-simple;}).package;

  # checks rust formatting
  checks.checks-rust-formatting =
    (lib.mkCrate {
      src = ./rust/hello-world;
      nativeBuildInputs = [cargoWrapper];
      packageAttrs.postCheck = ''
        grep 'cargo\ fmt\ --check' $out/cargo.log
      '';
    })
    .package;

  # TODO: buildPhase is can be overriden

  # rustToolchain can be overridden
  checks.can-override-rustToolchain = let
    expectedVersion = "1.60.0";
    rustToolchain = pkgs.rust-bin.stable.${expectedVersion}.default;
  in
    (lib.mkCrate {
      src = ./rust/hello-world;

      buildInputs = [pkgs.gawk];

      inherit rustToolchain;

      packageAttrs.preCheck = ''
        rustc_version=$(rustc --version | awk '{print $2}')
        if [ "$rustc_version"  != "${expectedVersion}" ]; then
          echo "Expected version ${expectedVersion} got $rustc_version"
          exit 1
        fi
      '';
    })
    .package;
in
  checks
