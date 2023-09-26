{
  pkgs,
  craneLib,
  ...
}: {
  inputsFrom ? [],
  checks ? {},
  packages ? [],
}:
craneLib.devShell {
  inputsFrom = (builtins.attrValues checks) ++ inputsFrom;

  packages =
    [
      pkgs.cargo-outdated
      pkgs.cargo-watch
      pkgs.cargo-bloat
      pkgs.cargo-udeps
      pkgs.cargo-edit
      pkgs.rust-analyzer
      pkgs.rustfmt
      pkgs.nixpkgs-fmt
    ]
    ++ packages;
}
