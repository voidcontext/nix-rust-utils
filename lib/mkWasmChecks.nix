{callPackage, ...}: {
  crate,
  src,
}: let
  mkChecks = callPackage ./mkChecks.nix {};
in
  mkChecks {
    inherit crate src;
    target = "wasm32-unknown-unkown";
    nextest = false;
  }
