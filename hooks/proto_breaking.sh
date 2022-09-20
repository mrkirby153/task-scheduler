#!/bin/env bash
set -e

if [ -z "$IN_NIX_SHELL" ]; then
    echo "Re-executing in nix-shell"
    exec nix-shell --command "$0 $@"
else
    branch=$(git rev-parse --abbrev-ref HEAD)
    buf breaking --against ".git#branch=$branch"
fi