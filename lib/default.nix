{ crane, ... }:

{ pkgs, rustToolchain, ... }:

with builtins;
let
  attrFromCargoToml = src: path: pkgs.lib.attrsets.getAttrFromPath path (fromTOML (readFile (src + "/Cargo.toml")));
  callPackage = pkgs.lib.callPackageWith { inherit pkgs rustToolchain crane callPackage attrFromCargoToml; };
in
{
  mkCrate = callPackage ./mkCrate.nix { };
  # TODO: mkWasmCrate does a bit more, it also generates JS bindings, its name should reflect this
  mkWasmCrateWithJSBindings = callPackage ./mkWasmCrateWithJSBindings.nix { };
}
