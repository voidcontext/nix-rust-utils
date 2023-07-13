{pkgs, ...}: {
  crate,
  checks ? {},
  buildInputs ? [],
  toolchain ? null,
}:
pkgs.mkShell {
  inputsFrom = (builtins.attrValues checks) ++ [crate];

  buildInputs =
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
    ++ buildInputs
    ++ pkgs.lib.optional (toolchain != null) toolchain;
}
