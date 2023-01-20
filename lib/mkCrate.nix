{
  pkgs,
  crane,
  rustToolchain,
  attrFromCargoToml,
  ...
} @ moduleArgs:
with builtins;
with pkgs.lib;
  {
    src,
    pname ? attrFromCargoToml src ["package" "name"],
    version ? attrFromCargoToml src ["package" "version"],
    rustToolchain ? moduleArgs.rustToolchain,
    buildInputs ? [],
    nativeBuildInputs ? [],
    cargoExtraArgs ? "",
    depsAttrs ? {},
    packageAttrs ? {},
    ...
  } @ args: let
    cleanedArgs = builtins.removeAttrs args [
      "rustToolchain"
      "depsAttrs"
      "packageAttrs"
    ];
    commonNativeBuildInputs =
      (optional pkgs.stdenv.isLinux pkgs.pkg-config)
      ++ [pkgs.cmake]
      ++ nativeBuildInputs;

    commonBuildInputs =
      (optional pkgs.stdenv.isLinux pkgs.openssl)
      ++ (optional (pkgs.system == "x86_64-darwin")
        pkgs.darwin.apple_sdk.frameworks.Security)
      ++ buildInputs;

    craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

    commonArgs =
      cleanedArgs
      // {
        inherit pname version;
        src = craneLib.cleanCargoSource src;

        buildInputs = commonBuildInputs;
        nativeBuildInputs = commonNativeBuildInputs;

        inherit cargoExtraArgs;
      };

    deps = craneLib.buildDepsOnly (depsAttrs // commonArgs);

    package = craneLib.buildPackage (packageAttrs
      // commonArgs
      // {
        cargoArtifacts = deps;

        preCheck = ''
          ${
            if (hasAttr "preCheck" packageAttrs)
            then packageAttrs.preCheck
            else ""
          }
          cargo fmt --check
          cargo clippy ${cargoExtraArgs} -- -W clippy::pedantic -A clippy::missing-errors-doc -A clippy::missing-panics-doc
        '';

        inherit cargoExtraArgs;
      });
  in {
    inherit
      package
      rustToolchain
      ;

    inherit
      (commonArgs)
      buildInputs
      nativeBuildInputs
      ;
  }
