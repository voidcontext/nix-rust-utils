{pkgs, ...}: {
  # TODO: make this configurable: ie: target, outdir, typscript, etc
  wasm.bindgen = {outDir ? "dist"}: ''
    for wasm in target/wasm32-unknown-unknown/release/*.wasm; do
      wasm-bindgen                                                          \
        --target web                                                        \
        --out-dir ${outDir}                                                 \
        --no-typescript                                                     \
        $wasm
    done
  '';

  utils.watch = path: cmd: let
    cmdBinName = pkgs.lib.strings.sanitizeDerivationName ("watch-" + path + "cmd");
    cmdBin = pkgs.writeShellScriptBin cmdBinName ''
      echo "-> Changed ${path}..."
      ${cmd}
      echo "-> Done."
    '';
  in ''
    ${cmdBin}/bin/${cmdBinName}
    ${pkgs.fswatch}/bin/fswatch -o ${path} | xargs -n1 sh -c '${cmdBin}/bin/${cmdBinName}' &
  '';
}
