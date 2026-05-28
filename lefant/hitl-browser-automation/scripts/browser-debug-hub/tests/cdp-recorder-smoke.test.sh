#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHROMIUM="${BDH_CHROMIUM:-${TOOLNIX_CHROMIUM:-${CHROMIUM_BIN:-$(command -v chromium 2>/dev/null || true)}}}"
if [ -z "$CHROMIUM" ] || [ ! -x "$CHROMIUM" ]; then
  echo "skip: chromium unavailable"
  exit 0
fi

state="$(mktemp -d)"
cleanup() {
  kill "${recorder_pid:-}" "${chromium_pid:-}" "${smoke_pid:-}" >/dev/null 2>&1 || true
  sleep 0.2
  rm -rf "$state" >/dev/null 2>&1 || true
}
trap cleanup EXIT

node "$ROOT/smoke-app/server.mjs" --host 127.0.0.1 --port 0 >"$state/smoke.log" 2>&1 &
smoke_pid=$!
for _ in $(seq 1 40); do [ -s "$state/smoke.log" ] && break; sleep 0.1; done
url="$(python3 - "$state/smoke.log" <<'PY'
import json, sys
print(json.loads(open(sys.argv[1]).readline())['url'])
PY
)"
cdp_port="$(python3 - <<'PY'
import socket
s=socket.socket(); s.bind(('127.0.0.1',0)); print(s.getsockname()[1]); s.close()
PY
)"
"$CHROMIUM" --headless=new --remote-debugging-address=127.0.0.1 --remote-debugging-port="$cdp_port" --user-data-dir="$state/profile" --no-sandbox --disable-gpu --disable-dev-shm-usage "$url" >"$state/chromium.log" 2>&1 &
chromium_pid=$!
for _ in $(seq 1 80); do curl -fsS "http://127.0.0.1:$cdp_port/json/version" >/dev/null 2>&1 && break; sleep 0.1; done
curl -fsS "http://127.0.0.1:$cdp_port/json/version" >/dev/null

node "$ROOT/recorder/cdp-recorder.mjs" --cdp-url "http://127.0.0.1:$cdp_port" --out-dir "$state/artifacts" --session-id test --reload-on-start true >"$state/recorder.log" 2>&1 &
recorder_pid=$!
for _ in $(seq 1 40); do [ -f "$state/artifacts/metadata.json" ] && break; sleep 0.1; done
printf '%s\n' smoke-checkpoint > "$state/artifacts/checkpoint-label.txt"
kill -USR2 "$recorder_pid"
sleep 1
kill -0 "$recorder_pid"
find "$state/artifacts/screenshots" -name '*smoke-checkpoint.png' -print -quit | grep -q .
curl -fsS -X POST "${url}api/click" -H 'content-type: application/json' --data '{"choice":"red"}' | jq -e '.sequence == ["red"]' >/dev/null
curl -fsS -X POST "${url}api/click" -H 'content-type: application/json' --data '{"choice":"green"}' | jq -e '.sequence == ["red", "green"]' >/dev/null
curl -fsS -X POST "${url}api/echo" -H 'content-type: application/json' --data '{"message":"cdp recorder"}' >/dev/null
sleep 1
kill -TERM "$recorder_pid" >/dev/null 2>&1 || true
wait "$recorder_pid" 2>/dev/null || true
jq -e '.log.entries | length >= 1' "$state/artifacts/network.har.json" >/dev/null
jq -e '[.log.entries[].request.url] | any(contains("/api/click"))' "$state/artifacts/network.har.json" >/dev/null
jq -e '.requestCount >= 1' "$state/artifacts/metadata.json" >/dev/null
jq -e '.screenshotCount >= 2' "$state/artifacts/metadata.json" >/dev/null
test -f "$state/artifacts/summary.md"

echo "cdp-recorder smoke tests passed"
