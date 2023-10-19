{
  pkgs,
  craneLib,
}: {
  commonArgs = {
    src,
    buildInputs,
    nativeBuildInputs,
    cargoExtraArgs,
    sourceFilter,
    target ? null,
  }: let
    crateSrc =
      if sourceFilter == null
      then craneLib.cleanCargoSource (craneLib.path src)
      else
        pkgs.lib.cleanSourceWith {
          inherit src;
          filter = sourceFilter;
        };
    targetArg =
      if target == null
      then ""
      else "--target=${target}";
  in {
    src = crateSrc;
    inherit buildInputs nativeBuildInputs;
    cargoExtraArgs = "${targetArg} ${cargoExtraArgs}";
  };
}
