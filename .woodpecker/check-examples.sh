#!/usr/bin/env bash
set -o pipefail 
set -e

for dir in examples/*; do                                                                   \
   cd $CI_WORKSPACE/$dir &&                                                                 \
   nix flake check 2>&1 |                                                                   \
        nix run "git+https://git.vdx.hu/voidcontext/nix-cache-copy?ref=refs/tags/v0.2.0" -- \
       -t file:///var/lib/woodpecker-agent/nix-store                                        \
       -k /var/lib/woodpecker-agent/nix-store/cache-priv-key.pem                            
done
