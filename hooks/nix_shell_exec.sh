#!/bin/env bash
set -e

if [ -z "$IN_NIX_SHELL" ]; then
    args="$@"
    nix-shell --run "$args"
else
    $@
fi
