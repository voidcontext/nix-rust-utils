{
  pkgs,
  craneLib,
  advisory-db,
  ...
}: {
  crate,
  src,
  target ? null,
  nextest ? false,
}: let
  utils = import ./utils.nix {inherit pkgs craneLib;};

  commonArgs = utils.commonArgs {inherit src target;};
  commonArgsWithoutTarget = utils.commonArgs {inherit src;};
  # Build *just* the cargo dependencies, so we can reuse
  # all of that work (e.g. via cachix) when running in CI
  cargoArtifacts = craneLib.buildDepsOnly commonArgsWithoutTarget;
in
  {
    # Build the crate as part of `nix flake check` for convenience
    inherit crate;

    # Run clippy (and deny all warnings) on the crate source,
    # again, resuing the dependency artifacts from above.
    #
    # Note that this is done as a separate derivation so that
    # we can block the CI if there are issues here, but not
    # prevent downstream consumers from building our crate by itself.
    cargo-clippy = craneLib.cargoClippy (commonArgsWithoutTarget
      // {
        inherit cargoArtifacts;
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
      });

    cargo-doc = craneLib.cargoDoc (commonArgsWithoutTarget
      // {
        inherit cargoArtifacts;
      });

    # Check formatting
    cargo-fmt = craneLib.cargoFmt {
      inherit (commonArgs) src;
    };

    # Audit dependencies
    cargo-audit = craneLib.cargoAudit {
      inherit (commonArgs) src;
      inherit advisory-db;
    };
  }
  // (
    if nextest
    then {
      # Run tests with cargo-nextest
      # Consider setting `doCheck = false` on `my-crate` if you do not want
      # the tests to run twice
      cargo-nextest = craneLib.cargoNextest (commonArgs
        // {
          inherit cargoArtifacts;
          partitions = 1;
          partitionType = "count";
        });
    }
    else {}
  )
# // pkgs.lib.optionalAttrs (pkgs.stdenv.system == "x86_64-linux") {
#   # NB: cargo-tarpaulin only supports x86_64 systems
#   # Check code coverage (note: this will not upload coverage anywhere)
#   cargo--coverage = craneLib.cargoTarpaulin (commonArgs
#     // {
#       inherit cargoArtifacts;
#     });
# }

