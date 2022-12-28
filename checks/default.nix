{ pkgs, mkLib, lib, rootDir, ... }:

let
  nixCommand = "${pkgs.nix}/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes";
  # Should build
  rust-binary-test = (lib.mkCrate { src = ./rust/package; }).package;

  rust-wasm = (lib.mkWasmCrate { src = ./rust/wasm-simple; }).package;

  # Should fail
  rust-binary-test-fmt-error = (lib.mkCrate { src = ./rust/package-with-fmt-error; }).package;
  rust-binary-test-custom-attrs = (lib.mkCrate pkgs { src = ./rust/package; buildPhase = "exit 1"; });
  rust-binary-test-rust-can-be-overridden = ((mkLib { inherit pkgs; rustToolchain = pkgs.rust-bin.stable."1.50.0".minimal; }).mkCrate { src = ./rust/package; }).package;

  assertFailure = name: pkgs.stdenv.mkDerivation {
    pname = "${name}-failure";
    version = "0.1.0";

    src = rootDir;

    buildInputs = [ pkgs.nix ];

    buildPhase = ''
      mkdir -p $out/home
      HOME=$out/home

      result=$(${nixCommand} build -L ${rootDir}#testPackages.${pkgs.system}.${name} 2>$out/build.log || echo "failed")

      if [ "$result" != "failed" ]; then
        echo "Build of ${name} didn't fail."
        exit 1
      fi
    '';

    installPhase = "echo 'Skipping installPhase...'";
  };

  assertResult = name: src: binName: expected: pkgs.stdenv.mkDerivation {
    pname = "${name}-result";
    version = "0.1.0";

    src = rootDir;

    buildInputs = [ pkgs.nix ];

    buildPhase = ''
      mkdir -p $out/home
      HOME=$out/home

      cd ${src}
      # patching the url of nix-rust-utils to the current source
      sed -i 's@"../../"@"${rootDir}"@' flake.nix

      ${nixCommand} build --show-trace

      result=$(./result/bin/${binName})

      echo "Result is '$result'";
      if [ "$result" != "${expected}" ]; then
        echo "Result was $result instead of '${expected}'."
        exit 1
      fi
    '';

    installPhase = "echo 'Skipping installPhase...'";
  };
in
rec {

  checks."lib.mkCrate.package" =
    rust-binary-test;

  checks."lib.mkWasmCrate.package" =
    rust-wasm;

  checks."lib.mkCrate.error.rust-binary-test-fmt-error" =
    assertFailure "rust-binary-test-fmt-error";

  checks."lib.mkCreate.error.rust-binary-test-custom-attrs" =
    assertFailure "rust-binary-test-custom-attrs";

  checks."lib.mkCreate.error.rust-binary-test-rust-can-be-overridden" =
    assertFailure "rust-binary-test-rust-can-be-overridden";

  checks."examples.mk-output-simple" =
    assertResult "mk-output-simple" "examples/mk-output-simple" "example-package" "Hello, world!";

  testPackages = {
    "check-example-mk-output-simple" =
      checks."examples.mk-output-simple";
    inherit
      rust-binary-test
      rust-binary-test-fmt-error
      rust-wasm
      rust-binary-test-custom-attrs
      rust-binary-test-rust-can-be-overridden;
  };
}
