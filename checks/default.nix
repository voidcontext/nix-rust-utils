pkgs: rust:

let
  rustBinaryTest = (rust.mkRustBinary pkgs { src = ./rust/package; });
in {
  "rust.mkRustBinary.package" =
    rustBinaryTest.package;

  "rust.mkRustBinary.app" = pkgs.stdenv.mkDerivation {
    name = "rust-mk-binary-app-test";

    src = ./.;

    buildPhase = ''
    mkdir -p $out
    output="$(${rustBinaryTest.app.program})"
    expected="Hello, world!"

    echo "Checking if $output == $expected"

    if [ "$output" != "$expected" ]; then
      exit 1
    fi
    '';

    installPhase = ''echo "Skipping installPhase..."'';
  };
}
