{callPackage, ...}: args: let
  mkChecks = callPackage ./mkChecks.nix {};
in
  mkChecks (
    args
    // {
      target = "wasm32-unknown-unkown";
      nextest = false;
    }
  )
