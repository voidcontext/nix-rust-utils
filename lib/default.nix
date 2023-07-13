{
  crane,
  advisory-db,
  ...
}: {
  pkgs,
  toolchain ? null,
  ...
}:
with builtins;
with pkgs.lib; let
  craneLib =
    if toolchain == null
    then crane.lib.${pkgs.stdenv.system}
    else (crane.mkLib pkgs).overrideToolchain toolchain;

  callPackage = pkgs.lib.callPackageWith {
    inherit
      pkgs
      craneLib
      callPackage
      advisory-db
      ;
  };

  snippets = callPackage ./snippets.nix {};
in {
  inherit craneLib;

  mkCrate = callPackage ./mkCrate.nix {};
  mkChecks = callPackage ./mkChecks.nix {};
  # TODO: mkWasmCrate does a bit more, it also generates JS bindings, its name should reflect this
  mkWasmCrate = callPackage ./mkWasmCrate.nix {};
  mkWasmChecks = callPackage ./mkWasmChecks.nix {};

  mkDevShell = callPackage ./mkDevShell.nix {};

  inherit snippets;

  utils.watch = pathCmds:
    foldl' (a: b: a + b) ""
    (attrsets.mapAttrsToList snippets.utils.watch pathCmds);
}
