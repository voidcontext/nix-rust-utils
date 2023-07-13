{
  pkgs,
  mkLib,
  rootDir,
  ...
}: let
  defaultLib = mkLib {inherit pkgs;};
  wasmLib = mkLib {
    inherit pkgs;
    toolchain = pkgs.rust-bin.stable.latest.default.override {
      targets = ["wasm32-unknown-unknown"];
    };
  };

  native-crate = defaultLib.mkCrate {src = ./rust/hello-world;};
  wasm32-crate = wasmLib.mkWasmCrate {src = ./rust/wasm-simple;};

  native-checks =
    pkgs.lib.attrsets.mapAttrs' (name: value: {
      name = "native-checks-${name}";
      inherit value;
    }) (defaultLib.mkChecks {
      crate = native-crate;
      src = ./rust/hello-world;
      nextest = true;
    });
  wasm32-checks =
    pkgs.lib.attrsets.mapAttrs' (name: value: {
      name = "wasm32-checks-${name}";
      inherit value;
    }) (wasmLib.mkWasmChecks {
      crate = wasm32-crate;
      src = ./rust/wasm-simple;
    });

  # test scenarios

  # can build rust package
  checks.can-build-rust-package = native-crate;
  # can build rust wasm package
  checks.can-build-rust-wasm-package = wasm32-crate;
in
  checks // native-checks // wasm32-checks
