{pkgs, ...}: {
  # TODO: make this configurable: ie: target, outdir, typscript, etc
  wasm.bindgen = {}: ''
    wasm-bindgen                                                          \
      --target web                                                        \
      --out-dir dist                                                      \
      --no-typescript                                                     \
      target/wasm32-unknown-unknown/release/*.wasm
  '';
}
