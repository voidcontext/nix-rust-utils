{
  apps.cargo = pkgs: {
    type = "app";
    program = "${pkgs.cargo}/bin/cargo";
  };

  mkRustBinary = pkgs: {src, rust ? null, name ? null}:
    let
      cargoToml = builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"));
      nameAttrs =
        if name == null then {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;
        }
        else {inherit name;}
      ;

      package = pkgs.rustPlatform.buildRustPackage (nameAttrs // {
        inherit src;

        nativeBuildInputs = with builtins; pkgs.lib.optional (! isNull rust) rust;

        cargoLock = {
          lockFile = src + "/Cargo.lock";
        };
      });

    in {
      app = {
        type = "app";
        program = "${package}/bin/${cargoToml.package.name}";
      };

      inherit package;
    };

}