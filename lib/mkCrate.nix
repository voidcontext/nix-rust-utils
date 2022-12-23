{ pkgs, crane, rustToolchain, attrFromCargoToml, ... }@moduleArgs:

with builtins;
with pkgs.lib;
{ src
, pname ? attrFromCargoToml src [ "package" "name" ]
, version ? attrFromCargoToml src [ "package" "version" ]
, rustToolchain ? moduleArgs.rustToolchain
, buildInputs ? [ ]
, nativeBuildInputs ? [ ]
, cargoExtraArgs ? ""
, depsHooks ? { }
, packageHooks ? { }
, ...
}@args:
let
  cleanedArgs = (builtins.removeAttrs args [
    "rustToolchain"
    "depsHooks"
    "packageHooks"
  ])
  ;
  commonNativeBuildInputs =
    nativeBuildInputs ++
    (optional pkgs.stdenv.isLinux pkgs.pkg-config) ++ [ pkgs.cmake ];

  commonBuildInputs =
    buildInputs ++
    (optional pkgs.stdenv.isLinux pkgs.openssl) ++
    (optional (pkgs.system == "x86_64-darwin")
      pkgs.darwin.apple_sdk.frameworks.Security);

  craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

  commonArgs = (cleanedArgs // {
    inherit pname version;
    src = craneLib.cleanCargoSource src;

    buildInputs = commonBuildInputs;
    nativeBuildInputs = commonNativeBuildInputs;

    inherit cargoExtraArgs;
  });

  deps = craneLib.buildDepsOnly (depsHooks // commonArgs);

  package = craneLib.buildPackage (packageHooks // commonArgs // {
    cargoArtifacts = deps;

    preCheck = ''
      ${ if (hasAttr "preCheck" packageHooks) then packageHooks.preCheck else ""}
      cargo fmt --check
      cargo clippy ${cargoExtraArgs} -- -W clippy::pedantic -A clippy::missing-errors-doc -A clippy::missing-panics-doc
    '';

    inherit cargoExtraArgs;
  });
in
{
  inherit
    package
    rustToolchain
    buildInputs
    nativeBuildInputs;
}
