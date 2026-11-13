#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
image="${1:?Usage: bash build.sh IMAGE:TAG}"

docker build --platform linux/amd64 -t "$image" .