{pkgs, ...}: {
  wasm.bindgen = {binaryName}: ''
    ${pkgs.tree}/bin/tree target
      wasm-bindgen                                                          \
        --target web                                                        \
        --out-dir dist                                                      \
        --no-typescript                                                     \
        target/wasm32-unknown-unknown/release/${binaryName}.wasm
  '';
}
