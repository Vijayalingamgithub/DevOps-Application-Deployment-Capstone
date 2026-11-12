#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
export APP_IMAGE="${1:?Usage: bash deploy.sh IMAGE:TAG}"

docker compose pull app
docker compose up -d --no-build app
curl -fsS --retry 10 --retry-connrefused --retry-delay 2 \
  http://127.0.0.1/healthz