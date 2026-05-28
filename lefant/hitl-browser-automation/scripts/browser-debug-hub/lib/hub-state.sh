#!/usr/bin/env bash
set -euo pipefail

BDH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "${BDH_STATE_ROOT:-}" ]; then
  state_base="${XDG_STATE_HOME:-$HOME/.local/state}/hitl-browser-automation"
  cwd_hash="$(pwd | cksum | awk '{print $1}')"
  cwd_name="$(basename "$PWD" | tr -cs '[:alnum:]_.-' '-' | sed 's/^-//; s/-$//')"
  BDH_STATE_ROOT="$state_base/${cwd_name:-project}-$cwd_hash"
fi

BDH_CURRENT_LINK="$BDH_STATE_ROOT/current"

bdh_now_id() {
  date -u +%Y%m%dT%H%M%SZ
}

bdh_session_dir() {
  local id="$1"
  printf '%s/sessions/%s\n' "$BDH_STATE_ROOT" "$id"
}

bdh_current_session_dir() {
  if [ -L "$BDH_CURRENT_LINK" ] || [ -e "$BDH_CURRENT_LINK" ]; then
    readlink -f "$BDH_CURRENT_LINK"
  else
    return 1
  fi
}

bdh_prepare_session() {
  local id="$1"
  local dir
  dir="$(bdh_session_dir "$id")"
  mkdir -p "$dir" "$dir/artifacts/screenshots" "$dir/profile-manual" "$dir/profile-replay" "$dir/logs"
  mkdir -p "$BDH_STATE_ROOT"
  ln -sfn "$dir" "$BDH_CURRENT_LINK"
  printf '%s\n' "$dir"
}

bdh_pid_alive() {
  local pid="${1:-}"
  [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1
}

bdh_read_meta() {
  local dir="${1:-}"
  if [ -z "$dir" ]; then
    dir="$(bdh_current_session_dir)"
  fi
  [ -f "$dir/metadata.json" ] || return 1
  cat "$dir/metadata.json"
}

bdh_meta_get() {
  local key="$1" dir="${2:-}"
  if [ -z "$dir" ]; then
    dir="$(bdh_current_session_dir)"
  fi
  jq -r "$key" "$dir/metadata.json"
}

bdh_write_metadata() {
  local path="$1"
  shift
  jq -n "$@" > "$path"
}

bdh_kill_pid_file() {
  local file="$1" label="$2"
  if [ ! -f "$file" ]; then
    return 0
  fi
  local pid
  pid="$(cat "$file" 2>/dev/null || true)"
  if bdh_pid_alive "$pid"; then
    echo "stopping $label pid=$pid"
    kill "$pid" >/dev/null 2>&1 || true
    for _ in 1 2 3 4 5; do
      if ! bdh_pid_alive "$pid"; then
        break
      fi
      sleep 0.3
    done
    if bdh_pid_alive "$pid"; then
      kill -9 "$pid" >/dev/null 2>&1 || true
    fi
  fi
}
