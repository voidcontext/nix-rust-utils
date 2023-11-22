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
  skipBuildDeps ? false,
  ...
} @ args: let
  cargoArtifacts =
    if skipBuildDeps
    then null
    else
      import ./internal/mkArtifacts.nix {
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
    "skipBuildDeps"
  ];
in
  # Build the actual crate itself, reusing the dependency
  # artifacts from above.
  craneLib.buildPackage (commonArgs
    // {
      inherit cargoArtifacts;
    }
    // cleanedArgs)
