{
  pkgs,
  callPackage,
  # attrFromCargoToml,
  ...
}: let
  mkCrate = callPackage ./mkCrate.nix {};
  snippets = callPackage ./snippets.nix {};
  testRunnerConfigured = src:
    with pkgs.lib;
    with builtins; let
      cargoConfig = src + "/.cargo/config";
    in
      sources.pathIsRegularFile (src + "/.cargo/config")
      && (attrsets.hasAttrByPath
        ["target" "wasm32-unknown-unknown" "runner"]
        (fromTOML (readFile cargoConfig)));
in
  {
    src,
    postBuild ? "",
    postInstall ? "",
    doCheck ? true,
    ...
  } @ args: let
    cleanedArgs = builtins.removeAttrs args [
      "postBuild"
      "postInstall"
      "doCheck"
    ];
  in
    assert pkgs.lib.asserts.assertMsg (!doCheck || (testRunnerConfigured src)) "doCheck must be false or a test runner must be configured";
      mkCrate (cleanedArgs
        // {
          inherit doCheck;
          target = "wasm32-unknown-unknown";

          buildInputs = [
            pkgs.binaryen
            pkgs.wasm-bindgen-cli
          ];

          # TODO: make the generation of JS bindings optional and configurable
          postBuild = ''
            ${snippets.wasm.bindgen {}}
            ${postBuild}
          '';

          postInstall = ''
            cp dist/* $out/lib

            ${postInstall}
          '';
        })
