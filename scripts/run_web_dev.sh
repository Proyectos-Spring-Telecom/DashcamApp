#!/usr/bin/env bash
# Desarrollo Flutter Web con proxy CORS local.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROXY_PORT="${WEB_DEV_PROXY_PORT:-8090}"
MAPS_KEY="$(grep 'google.maps.api.key' android/local.properties | cut -d= -f2)"

echo "▶ Iniciando proxy API en http://127.0.0.1:${PROXY_PORT}/apipay"
dart run tool/dev_api_proxy.dart "$PROXY_PORT" &
PROXY_PID=$!

cleanup() {
  kill "$PROXY_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

sleep 1

echo "▶ Iniciando Flutter Web (Chrome)"
flutter run -d chrome \
  --dart-define=GOOGLE_MAPS_API_KEY="$MAPS_KEY" \
  --dart-define-from-file=.env
