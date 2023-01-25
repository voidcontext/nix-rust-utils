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

  wasm.buildExample = name: ''
    cargo build --release --example ${name} --target=wasm32-unknown-unknown

    cp target/wasm32-unknown-unknown/release/examples/${name}.wasm target/wasm32-unknown-unknown/release
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

  utils.serve = src: port: ''
    ${pkgs.simple-http-server}/bin/simple-http-server \
      -p ${builtins.toString port}                    \
      --nocache                                       \
      -i --try-file ${src}/index.html                 \
      -- ${src}
  '';

  utils.cleanupWrapper = body: ''
    # https://unix.stackexchange.com/a/55922
    trap 'cleanup' INT TERM
    cleanup() {
        trap "" INT TERM  # ignore INT and TERM while shutting down
        echo "**** Shutting down... ****"
        ${pkgs.coreutils}/bin/kill -TERM 0
        wait
        echo DONE
    }

    ${body}

    cleanup
  '';
}
