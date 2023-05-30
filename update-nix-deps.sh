#!/usr/bin/env sh
echo "Updating Mix dependencies..."

nix develop --command "mix2nix" > mix_deps.nix