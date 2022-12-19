{ pkgs, rust, ... }:

let
  # Should build
  rust-binary-test = (rust.mkCrate { src = ./rust/package; });

  # Should fail
  rust-binary-test-fmt-error = (rust.mkCrate { src = ./rust/package-with-fmt-error; });
  # rust-binary-test-custom-attrs = (rust.mkCrate pkgs { src = ./rust/package; buildPhase = "exit 1"; });
  rust-binary-test-rust-can-be-overridden = (rust.mkCrate { src = ./rust/package; rustToolchain = pkgs.rust-bin.stable."1.50.0".minimal; });

  assert-build-failure = pkgs.writeScriptBin "assert-build-failure" ''
    test_package=$1

    result=$(${pkgs.nix}/bin/nix build .#testPackages.${pkgs.system}.$test_package || echo "failed")

    if [ "$result" != "failed" ]; then
      echo "Build of $test_package didn't fail."
      exit 1
    fi
  '';

  check-builds-failing = pkgs.writeScriptBin "check-builds-failing" ''
    set -e
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-fmt-error"
    # ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-custom-attrs"
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-rust-can-be-overridden"
  '';
in
{

  checks."rust.mkCrate.package" =
    rust-binary-test;

  scripts = {
    inherit check-builds-failing;
  };

  testPackages = {
    inherit
      rust-binary-test-fmt-error
      # rust-binary-test-custom-attrs
      rust-binary-test-rust-can-be-overridden;
  };
}
