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
  cargoArtifacts = import ./internal/mkArtifacts.nix {
    inherit
      pkgs
      craneLib
      src
      buildInputs
      cargoExtraArgs
      ;
  };

  utils = import ./utils.nix {inherit pkgs craneLib;};
  commonArgs = utils.commonArgs {inherit src buildInputs target cargoExtraArgs;};
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
