#!/usr/bin/env bash

nix_store_dir=/var/lib/woodpecker-agent/nix-store
nix_store_uri=file://$nix_store_dir

cat <<EOF >> /etc/nix/nix.conf
experimental-features = nix-command flakes
trusted-substituters = $nix_store_uri
extra-trusted-public-keys = $(cat $nix_store_dir/cache-pub-key.pem)
extra-substituters = $nix_store_uri
EOF