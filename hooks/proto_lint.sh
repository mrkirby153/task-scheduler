#!/bin/env bash
set -e
pushd proto > /dev/null
buf lint
popd > /dev/null