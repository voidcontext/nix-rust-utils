{ pkgs, crane, rustToolchain, attrFromCargoToml, ... }@moduleArgs:

with builtins;
with pkgs.lib;
{ src
, pname ? attrFromCargoToml src [ "package" "name" ]
, version ? attrFromCargoToml src [ "package" "version" ]
, rustToolchain ? moduleArgs.rustToolchain
, buildInputs ? [ ]
, doCheck ? true
, cargoExtraArgs ? ""
, packagePostBuild ? ""
}:
let
  nativeBuildInputs =
    (optional pkgs.stdenv.isLinux pkgs.pkg-config) ++ [ pkgs.cmake ];

  crateBuildInputs =
    buildInputs ++
    (optional pkgs.stdenv.isLinux pkgs.openssl) ++
    (optional (pkgs.system == "x86_64-darwin")
      pkgs.darwin.apple_sdk.frameworks.Security);

  craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

  commonArgs = {
    inherit pname version;
    src = craneLib.cleanCargoSource src;

    buildInputs = crateBuildInputs;

    inherit doCheck cargoExtraArgs nativeBuildInputs;
  };

  deps = craneLib.buildDepsOnly commonArgs;

  package = craneLib.buildPackage (commonArgs // {
    cargoArtifacts = deps;

    preCheck = ''
      cargo fmt --check
      cargo clippy ${cargoExtraArgs} -- -W clippy::pedantic -A clippy::missing-errors-doc -A clippy::missing-panics-doc
    '';

    postBuild = packagePostBuild;

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
