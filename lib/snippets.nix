{pkgs, ...}: {

  # TODO: make this configurable: ie: target, outdir, typscript, etc
  wasm.bindgen = {}: ''
    for wasm in target/wasm32-unknown-unknown/release/*.wasm; do
      wasm-bindgen                                                          \
        --target web                                                        \
        --out-dir dist                                                      \
        --no-typescript                                                     \
        $wasm
    done
  '';
}
