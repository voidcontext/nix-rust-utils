{
  pkgs,
  craneLib,
  ...
}: {
  src,
  buildInputs ? [],
  nativeBuildInputs ? [],
  cargoExtraArgs ? "",
  target ? null,
  sourceFilter ? null,
  ...
} @ args: let
  cargoArtifacts = import ./internal/mkArtifacts.nix {
    inherit
      pkgs
      craneLib
      src
      buildInputs
      nativeBuildInputs
      cargoExtraArgs
      sourceFilter
      ;
  };

  utils = import ./utils.nix {inherit pkgs craneLib;};
  commonArgs = utils.commonArgs {
    inherit
      src
      nativeBuildInputs
      buildInputs
      target
      cargoExtraArgs
      sourceFilter
      ;
  };
  cleanedArgs = builtins.removeAttrs args [
    "src"
    "cargoExtraArgs"
    "target"
    "sourceFilter"
  ];
in
  # Build the actual crate itself, reusing the dependency
  # artifacts from above.
  craneLib.buildPackage (commonArgs
    // {
      inherit cargoArtifacts;
    }
    // cleanedArgs)
