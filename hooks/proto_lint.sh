#!/bin/env bash
set -e
if [ -z "$IN_NIX_SHELL" ]; then
    echo "Re-executing in nix-shell"
    exec nix-shell --command "$0 $@"
else
    pushd proto > /dev/null
    buf lint
    popd > /dev/null
fi