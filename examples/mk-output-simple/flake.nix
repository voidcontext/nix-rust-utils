{
  inputs.nixpgks.url = "nixpkgs/release-23.05";
  inputs.nix-rust-utils.url = "../../";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-rust-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      nru = nix-rust-utils.mkLib {inherit pkgs;};
      src = ./.;
      crate = nru.mkCrate {inherit src;};
      checks = nru.mkChecks {inherit src crate;};
    in {
      inherit checks;

      packages.default = crate;

      devShells.default = nru.mkDevShell {inputsFrom = [crate]; inherit checks;};
    });
}
