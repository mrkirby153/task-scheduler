#!/bin/env bash
set -e
branch=$(git rev-parse --abbrev-ref HEAD)
buf breaking --against ".git#branch=$branch"