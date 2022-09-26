#!/bin/env bash
set -e

if [ -z "$IN_NIX_SHELL" ]; then
    echo "Re-executing in nix-shell"
    nix-shell --command "$@"
else
    exec "$@"
fi