{
  apps.cargo = { pkgs, buildInputs ? [ ], cargo ? pkgs.cargo }:
    let cargoPackage = cargo.overrideAttrs (oldAttrs: {
      buildInputs =
        (pkgs.lib.lists.optionals (builtins.hasAttr "buildInputs" oldAttrs) oldAttrs.buildInputs)
        ++ buildInputs;
    });
    in
    {
      type = "app";
      program = "${cargoPackage}/bin/cargo";
    };

  mkRustBinary = pkgs:
    with builtins;
    { src
    , checkFmt ? true
    , rust ? null
    , name ? null
    , crateRoot ? src
    , nativeBuildInputs ? [ ]
    , preCheck ? ""
    , ...
    }@args:
    let
      root = if isPath crateRoot then crateRoot else src + "/${crateRoot}";
      cargoToml = builtins.fromTOML (builtins.readFile (root + "/Cargo.toml"));
      nameAttrs =
        if name == null then {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;
        }
        else { inherit name; }
      ;
      setSourceRoot =
        if crateRoot == src then { }
        else { setSourceRoot = ''sourceRoot=$(echo */${crateRoot})''; };
    in
    pkgs.rustPlatform.buildRustPackage (nameAttrs // setSourceRoot // args // {
      nativeBuildInputs =
        nativeBuildInputs ++
          (pkgs.lib.optional (! isNull rust) rust) ++
          (pkgs.lib.optionals (checkFmt) [ pkgs.rustfmt ]);

      preCheck =
        if checkFmt
        then ''
          cargo fmt --check
          ${preCheck}
        ''
        else preCheck;

      cargoLock = {
        lockFile = root + "/Cargo.lock";
      };

    });

}
