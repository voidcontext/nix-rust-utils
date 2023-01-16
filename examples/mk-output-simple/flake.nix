{
  inputs.nix-rust-utils.url = "../../";
  outputs = {nix-rust-utils, ...}:
    nix-rust-utils.lib.mkOutputs ({...}: {src = ./.;});
}
