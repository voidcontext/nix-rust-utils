{
  pkgs,
  pkgsUnstable,
  ...
}: let
  versions = import ../packages/versions.nix;
in
  crate:
    pkgs.mkShell {
      buildInputs =
        crate.nativeBuildInputs
        ++ crate.buildInputs
        ++ [
          crate.rustToolchain
          (versions {
            inherit pkgs pkgsUnstable;
            inherit (crate) rustToolchain;
          })
          pkgs.cargo-outdated
          pkgs.cargo-watch
          pkgs.cargo-bloat
          pkgs.cargo-udeps
          pkgsUnstable.rust-analyzer
          pkgs.rustfmt
          pkgs.nixpkgs-fmt
        ];
    }
