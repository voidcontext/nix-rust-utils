{crane, ...}: {
  pkgs,
  rustToolchain,
  ...
}:
with builtins;
with pkgs.lib; let
  attrFromCargoToml = src: path: attrsets.getAttrFromPath path (fromTOML (readFile (src + "/Cargo.toml")));
  callPackage = pkgs.lib.callPackageWith {inherit pkgs rustToolchain crane callPackage attrFromCargoToml;};
  snippets = callPackage ./snippets.nix {};
in {
  mkCrate = callPackage ./mkCrate.nix {};
  # TODO: mkWasmCrate does a bit more, it also generates JS bindings, its name should reflect this
  mkWasmCrate = callPackage ./mkWasmCrate.nix {};

  mkDevShell = callPackage ./mkDevShell.nix {};

  inherit snippets;

  utils.watch = pathCmds:
    foldl' (a: b: a + b) ""
    (attrsets.mapAttrsToList snippets.utils.watch pathCmds);
}
