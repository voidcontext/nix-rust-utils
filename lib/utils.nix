{
  pkgs,
  craneLib,
}: {
  commonArgs = {
    src,
    buildInputs ? [],
    buildInputsDarwin ? [],
    cargoExtraArgs ? "",
    target ? null,
  }: let
    crateSrc = craneLib.cleanCargoSource (craneLib.path src);
    bi = buildInputs ++ pkgs.lib.optionals pkgs.stdenv.isDarwin buildInputsDarwin;
    targetArg =
      if target == null
      then ""
      else "--target=${target}";
  in {
    src = crateSrc;
    buildInputs = bi;
    cargoExtraArgs = "${targetArg} ${cargoExtraArgs}";
  };
}
