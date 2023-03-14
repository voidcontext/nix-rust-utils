{
  pkgs,
  pkgsUnstable,
  rustToolchain,
  ...
}:
pkgs.writeShellScriptBin "versions" ''
  echo "nixpkgs: ${pkgs.lib.version}"
  ${rustToolchain}/bin/rustc --version
  ${rustToolchain}/bin/cargo --version
  ${pkgsUnstable.rust-analyzer}/bin/rust-analyzer --version
''
