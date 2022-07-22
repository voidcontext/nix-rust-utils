pkgs: system: rust:

let
  rust-binary-test = (rust.mkRustBinary pkgs { src = ./rust/package; });
  rust-binary-test-fmt-error = (rust.mkRustBinary pkgs { src = ./rust/package-with-fmt-error; });

  assert-build-failure = pkgs.writeScriptBin "assert-build-failure" ''
  test_package=$1

  result=$(${pkgs.nix}/bin/nix build .#testPackages.${system}.$test_package.package || echo "failed")

  if [ "$result" != "failed" ]; then
    echo "Build of $test_package didn't fail."
    exit 1
  fi
  '';

  check-builds-failing = pkgs.writeScriptBin "check-builds-failing" ''
  ${assert-build-failure}/bin/assert-build-failure "rust-binary-test-fmt-error"
  '';
in {

  checks."rust.mkRustBinary.package" =
    rust-binary-test.package;

  checks."rust.mkRustBinary.app" = pkgs.stdenv.mkDerivation {
    name = "rust-mk-binary-app-test";

    src = ./.;

    buildPhase = ''
    mkdir -p $out
    output="$(${rust-binary-test.app.program})"
    expected="Hello, world!"

    echo "Checking if $output == $expected"

    if [ "$output" != "$expected" ]; then
      exit 1
    fi
    '';

    installPhase = ''echo "Skipping installPhase..."'';
  };

  scripts = {
    inherit check-builds-failing;
  };

  testPackages = {
    inherit rust-binary-test-fmt-error;
  };
}
