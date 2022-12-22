{ crane, ... }:

{ pkgs, rustToolchain, ... }:

let
  callPackage = pkgs.lib.callPackageWith { inherit pkgs rustToolchain crane; };
in
{
  mkCrate = callPackage ./mkCrate.nix { };
}
