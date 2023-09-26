{
  pkgs,
  craneLib,
}: {
  commonArgs = {
    src,
    buildInputs,
    cargoExtraArgs,
    target ? null,
  }: let
    crateSrc = craneLib.cleanCargoSource (craneLib.path src);
    targetArg =
      if target == null
      then ""
      else "--target=${target}";
  in {
    src = crateSrc;
    inherit buildInputs;
    cargoExtraArgs = "${targetArg} ${cargoExtraArgs}";
  };
}
