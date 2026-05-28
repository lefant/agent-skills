#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${BDH_TEST_SMOKE_PORT:-0}"
LOG="$(mktemp)"
node "$ROOT/smoke-app/server.mjs" --host 127.0.0.1 --port "$PORT" >"$LOG" 2>&1 &
pid=$!
cleanup() { kill "$pid" >/dev/null 2>&1 || true; rm -f "$LOG"; }
trap cleanup EXIT

for _ in $(seq 1 40); do
  if [ -s "$LOG" ]; then break; fi
  sleep 0.1
done
URL="$(python3 - "$LOG" <<'PY'
import json, sys, time
path = sys.argv[1]
for _ in range(20):
    try:
        line = open(path).readline()
        if line:
            print(json.loads(line)['url'])
            raise SystemExit
    except Exception:
        time.sleep(0.1)
raise SystemExit(1)
PY
)"

echo "smoke url: $URL"
curl -fsS "$URL" | grep -q 'Browser Debug Hub Smoke App'
curl -fsS "$URL" | grep -q 'Objective demo buttons'
curl -fsS "${URL}api/state" | jq -e '.ok == true and .state == "ready" and .sequence == []' >/dev/null
curl -fsS -X POST "${URL}api/click" -H 'content-type: application/json' --data '{"choice":"red"}' | jq -e '.ok == true and .sequence == ["red"] and .finalChoice == "red"' >/dev/null
curl -fsS -X POST "${URL}api/click" -H 'content-type: application/json' --data '{"choice":"blue"}' | jq -e '.ok == true and .sequence == ["red", "blue"] and .finalChoice == "blue"' >/dev/null
status="$(curl -sS -o /tmp/bdh-smoke-choice-error.json -w '%{http_code}' -X POST "${URL}api/click" -H 'content-type: application/json' --data '{"choice":"purple"}')"
[ "$status" = "422" ]
jq -e '.error == "invalid_choice"' /tmp/bdh-smoke-choice-error.json >/dev/null
status="$(curl -sS -o /tmp/bdh-smoke-click-json-error.json -w '%{http_code}' -X POST "${URL}api/click" -H 'content-type: application/json' --data '{bad json')"
[ "$status" = "400" ]
jq -e '.error == "invalid_json"' /tmp/bdh-smoke-click-json-error.json >/dev/null
curl -fsS -X POST "${URL}api/reset" -H 'content-type: application/json' --data '{}' | jq -e '.ok == true and .sequence == [] and .count == 0' >/dev/null
curl -fsS -X POST "${URL}api/echo" -H 'content-type: application/json' --data '{"message":"test replay"}' | jq -e '.ok == true and .replayToken == "bdh-746573742072"' >/dev/null
status="$(curl -sS -o /tmp/bdh-smoke-json-error.json -w '%{http_code}' -X POST "${URL}api/echo" -H 'content-type: application/json' --data '{bad json')"
[ "$status" = "400" ]
jq -e '.error == "invalid_json"' /tmp/bdh-smoke-json-error.json >/dev/null
status="$(curl -sS -o /tmp/bdh-smoke-error.json -w '%{http_code}' -X POST "${URL}api/echo" -H 'content-type: application/json' --data '{}')"
[ "$status" = "422" ]
jq -e '.error == "message_required"' /tmp/bdh-smoke-error.json >/dev/null

echo "smoke-app tests passed"
