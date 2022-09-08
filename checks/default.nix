pkgs: system: rust:

let
  # Should build
  rust-binary-test = (rust.mkRustBinary pkgs { src = ./rust/package; });
  rust-binary-test-source-root = (rust.mkRustBinary pkgs { src = ./rust/non-root-package; crateRoot = "package"; });
  rust-binary-test-disable-fmt-check = (rust.mkRustBinary pkgs { src = ./rust/package-with-fmt-error; checkFmt = false; });

  # Should fail
  rust-binary-test-fmt-error = (rust.mkRustBinary pkgs { src = ./rust/package-with-fmt-error; });
  rust-binary-test-custom-attrs = (rust.mkRustBinary pkgs { src = ./rust/package; buildPhase = "exit 1"; });
  rust-binary-test-rust-can-be-overridden = (rust.mkRustBinary pkgs { src = ./rust/package-with-fmt-error; rust = pkgs.rust-bin.stable."1.50.0".minimal; });

  assert-build-failure = pkgs.writeScriptBin "assert-build-failure" ''
    test_package=$1

    result=$(${pkgs.nix}/bin/nix build .#testPackages.${system}.$test_package || echo "failed")

    if [ "$result" != "failed" ]; then
      echo "Build of $test_package didn't fail."
      exit 1
    fi
  '';

  check-builds-failing = pkgs.writeScriptBin "check-builds-failing" ''
    set -e
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-fmt-error"
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-custom-attrs"
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-rust-can-be-overridden"
  '';
in
{

  checks."rust.mkRustBinary.package" =
    rust-binary-test;

  checks."rust.mkRustBinary.package-source-root" =
    rust-binary-test-source-root;

  checks."rust.mkRustBinary.package.disable-fmt-check" =
    rust-binary-test-disable-fmt-check;

  checks."rust.apps.cargo" =
    pkgs.writeScriptBin "cargo-check" ''
      ${(rust.apps.cargo {inherit pkgs;}).program}
    '';

  scripts = {
    inherit check-builds-failing;
  };

  testPackages = {
    inherit
      rust-binary-test-fmt-error
      rust-binary-test-custom-attrs
      rust-binary-test-rust-can-be-overridden;
  };
}
