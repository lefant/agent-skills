#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HUB="$ROOT/bin/browser-debug-hub"

json="$($HUB check --json)"
echo "$json" | jq -e 'has("ok") and has("chromium") and has("vncMode") and has("agentBrowser")' >/dev/null

if echo "$json" | jq -e '.ok == true' >/dev/null; then
  echo "runtime dependencies present; exercising start/status/stop safety"
  state_root="$(mktemp -d)"
  cleanup() { BDH_STATE_ROOT="$state_root" "$HUB" stop >/dev/null 2>&1 || true; rm -rf "$state_root"; }
  trap cleanup EXIT
  BDH_STATE_ROOT="$state_root" "$HUB" start >/tmp/bdh-launcher-start.log
  status="$(BDH_STATE_ROOT="$state_root" "$HUB" status --json)"
  echo "$status" | jq -e '.metadata.cdp.bind == "127.0.0.1" and .metadata.vnc.bind == "127.0.0.1"' >/dev/null
  BDH_STATE_ROOT="$state_root" "$HUB" stop >/dev/null
  trap - EXIT
  rm -rf "$state_root"
else
  echo "runtime dependencies incomplete; check command reported missing tools as expected"
fi

echo "launcher-safety tests passed"
