{ pkgs, mkLib, lib, ... }:

let
  # Should build
  rust-binary-test = (lib.mkCrate { src = ./rust/package; }).package;

  # Should fail
  rust-binary-test-fmt-error = (lib.mkCrate { src = ./rust/package-with-fmt-error; }).package;
  # rust-binary-test-custom-attrs = (lib.mkCrate pkgs { src = ./rust/package; buildPhase = "exit 1"; });
  rust-binary-test-rust-can-be-overridden = ((mkLib { inherit pkgs; rustToolchain = pkgs.rust-bin.stable."1.50.0".minimal; }).mkCrate { src = ./rust/package; }).package;

  assert-build-failure = pkgs.writeScriptBin "assert-build-failure" ''
    test_package=$1

    result=$(${pkgs.nix}/bin/nix build .#testPackages.${pkgs.system}.$test_package || echo "failed")

    if [ "$result" != "failed" ]; then
      echo "Build of $test_package didn't fail."
      exit 1
    fi
  '';

  assert-build-success-in-dir = pkgs.writeScriptBin "assert-nix-build-success" ''
    dir=$1

    path=checks/nix/$dir

    cd $path

    nix build

    result=$(./result/bin/example-package)

    if [ "$result" != "Hello, world!" ]; then
      echo "Result was $result instead of 'Hello, world!'."
      exit 1
    fi
  '';

  check-builds = pkgs.writeScriptBin "check-builds" ''
    set -e
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-fmt-error"
    # ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-custom-attrs"
    ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-rust-can-be-overridden"

    ${assert-build-success-in-dir}/bin/assert-nix-build-success mk-output-simple
  '';
in
{

  checks."lib.mkCrate.package" =
    rust-binary-test;

  scripts = {
    inherit check-builds;
  };

  testPackages = {
    inherit
      rust-binary-test-fmt-error
      # rust-binary-test-custom-attrs
      rust-binary-test-rust-can-be-overridden;
  };
}
