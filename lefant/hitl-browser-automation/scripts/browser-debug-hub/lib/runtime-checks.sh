#!/usr/bin/env bash
set -euo pipefail

bdh_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

bdh_resolve_command() {
  local name="$1"
  command -v "$name" 2>/dev/null || return 1
}

bdh_find_chromium() {
  local candidate
  for candidate in \
    "${BDH_CHROMIUM:-}" \
    "${TOOLNIX_CHROMIUM:-}" \
    "${CHROMIUM_BIN:-}" \
    "${CHROME_BIN:-}" \
    "${AGENT_BROWSER_EXECUTABLE_PATH:-}" \
    "${PUPPETEER_EXECUTABLE_PATH:-}"; do
    if [ -n "${candidate:-}" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  for candidate in chromium google-chrome-stable google-chrome; do
    if bdh_command_exists "$candidate"; then
      bdh_resolve_command "$candidate"
      return 0
    fi
  done

  return 1
}

bdh_find_agent_browser() {
  bdh_resolve_command agent-browser
}

bdh_find_vnc_mode() {
  if bdh_command_exists Xtigervnc; then
    printf 'tigervnc:%s\n' "$(bdh_resolve_command Xtigervnc)"
    return 0
  fi

  if bdh_command_exists Xvnc; then
    printf 'tigervnc:%s\n' "$(bdh_resolve_command Xvnc)"
    return 0
  fi

  if bdh_command_exists Xvfb && bdh_command_exists x11vnc; then
    printf 'xvfb-x11vnc:%s:%s\n' "$(bdh_resolve_command Xvfb)" "$(bdh_resolve_command x11vnc)"
    return 0
  fi

  return 1
}

bdh_find_window_manager() {
  local candidate
  for candidate in fluxbox openbox twm; do
    if bdh_command_exists "$candidate"; then
      bdh_resolve_command "$candidate"
      return 0
    fi
  done
  return 1
}

bdh_check_required() {
  local missing=0
  local chromium

  if ! chromium="$(bdh_find_chromium)"; then
    echo "missing: Chromium/Chrome runtime (set BDH_CHROMIUM or install chromium)" >&2
    missing=1
  else
    echo "chromium: $chromium"
  fi

  for cmd in node jq python3; do
    if ! bdh_command_exists "$cmd"; then
      echo "missing: $cmd" >&2
      missing=1
    else
      echo "$cmd: $(bdh_resolve_command "$cmd")"
    fi
  done

  if ! bdh_find_agent_browser >/dev/null 2>&1; then
    echo "missing: agent-browser" >&2
    missing=1
  else
    echo "agent-browser: $(bdh_find_agent_browser)"
  fi

  if ! bdh_find_vnc_mode >/dev/null 2>&1; then
    echo "missing: VNC/display stack (preferred: tigervnc; fallback: Xvfb + x11vnc)" >&2
    missing=1
  else
    echo "vnc-mode: $(bdh_find_vnc_mode)"
  fi

  return "$missing"
}

bdh_check_required_json() {
  local chromium="" agent_browser="" vnc_mode="" wm="" ok=true
  chromium="$(bdh_find_chromium 2>/dev/null || true)"
  agent_browser="$(bdh_find_agent_browser 2>/dev/null || true)"
  vnc_mode="$(bdh_find_vnc_mode 2>/dev/null || true)"
  wm="$(bdh_find_window_manager 2>/dev/null || true)"

  if [ -z "$chromium" ] || [ -z "$agent_browser" ] || [ -z "$vnc_mode" ] || ! bdh_command_exists node || ! bdh_command_exists jq || ! bdh_command_exists python3; then
    ok=false
  fi

  jq -n \
    --argjson ok "$ok" \
    --arg chromium "$chromium" \
    --arg agentBrowser "$agent_browser" \
    --arg vncMode "$vnc_mode" \
    --arg windowManager "$wm" \
    --arg node "$(bdh_resolve_command node 2>/dev/null || true)" \
    --arg jqPath "$(bdh_resolve_command jq 2>/dev/null || true)" \
    --arg python3 "$(bdh_resolve_command python3 2>/dev/null || true)" \
    '{ok: $ok, chromium: $chromium, agentBrowser: $agentBrowser, vncMode: $vncMode, windowManager: $windowManager, node: $node, jq: $jqPath, python3: $python3}'

  [ "$ok" = true ]
}
