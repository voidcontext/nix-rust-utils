{
  pkgs,
  craneLib,
  ...
}: {
  src,
  buildInputs ? [],
  cargoExtraArgs ? "",
  target ? null,
  ...
} @ args: let
  utils = import ./utils.nix {inherit pkgs craneLib;};
  commonArgs = utils.commonArgs {inherit src buildInputs target cargoExtraArgs;};
  # Build *just* the cargo dependencies, so we can reuse
  # all of that work (e.g. via cachix) when running in CI
  cargoArtifacts = craneLib.buildDepsOnly (
    # Please note target is intentionnally omitted here
    utils.commonArgs {inherit src buildInputs cargoExtraArgs;}
  );

  cleanedArgs = builtins.removeAttrs args [
    "src"
    "cargoExtraArgs"
    "target"
  ];
in
  # Build the actual crate itself, reusing the dependency
  # artifacts from above.
  craneLib.buildPackage (commonArgs
    // {
      inherit cargoArtifacts;
    }
    // cleanedArgs)
