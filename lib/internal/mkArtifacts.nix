{
  pkgs,
  craneLib,
  src,
  buildInputs,
  cargoExtraArgs,
}: let
  utils = import ../utils.nix {inherit pkgs craneLib;};
  # Build *just* the cargo dependencies, so we can reuse
  # all of that work (e.g. via cachix) when running in CI
  cargoArtifacts = craneLib.buildDepsOnly (
    # Please note target is intentionnally omitted here
    utils.commonArgs {inherit src buildInputs cargoExtraArgs;}
  );
in
  cargoArtifacts
