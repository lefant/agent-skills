#!/usr/bin/env bash
# fleet-common.sh — shared library for exe.dev fleet management scripts
#
# Source this file, don't execute it directly.
# Provides: VM discovery, SSH helpers, parallel probe execution.
#
# Environment:
#   EXE_DEV_SSH_KEY  — path to SSH private key (optional, uses ssh-agent/config by default)
#   EXE_DEV_SSH_USER — remote username (default: exedev)
#   EXE_DEV_TIMEOUT  — SSH connect timeout in seconds (default: 5)

set -euo pipefail

_FLEET_SSH_USER="${EXE_DEV_SSH_USER:-exedev}"
_FLEET_TIMEOUT="${EXE_DEV_TIMEOUT:-5}"
_FLEET_SSH_OPTS="-o ConnectTimeout=${_FLEET_TIMEOUT} -o StrictHostKeyChecking=accept-new -o BatchMode=yes"
_FLEET_LOCAL_FQDN="$(hostname -f 2>/dev/null || true)"
_FLEET_LOCAL_SHORT="$(hostname -s 2>/dev/null || true)"

if [ -n "${EXE_DEV_SSH_KEY:-}" ]; then
  _FLEET_SSH_OPTS="$_FLEET_SSH_OPTS -i $EXE_DEV_SSH_KEY"
fi

# fleet_ssh <host.exe.xyz> <command>
# Run a command on a single VM. Returns the remote stdout.
fleet_ssh() {
  local host="$1" cmd="$2"
  local short_host="${host%%.*}"

  if [ "$host" = "$_FLEET_LOCAL_FQDN" ] || [ "$short_host" = "$_FLEET_LOCAL_SHORT" ]; then
    bash -lc "$cmd"
    return
  fi

  # shellcheck disable=SC2086
  ssh $_FLEET_SSH_OPTS "${_FLEET_SSH_USER}@${host}" "$cmd" 2>/dev/null
}

# discover_vms
# List all exe.dev VM names (one per line) via the exe.dev API.
discover_vms() {
  ssh exe.dev ls --json 2>/dev/null | jq -r '.vms[].vm_name'
}

# discover_vms_json
# Return full exe.dev VM list as JSON.
discover_vms_json() {
  ssh exe.dev ls --json 2>/dev/null
}

# parallel_probe <probe_command> [vm_name ...]
# Run probe_command on each VM in parallel (max 5 concurrent).
# If no VM names given, discovers all VMs automatically.
# Outputs: vm_name<TAB>output lines per host.
# Failed probes output: vm_name<TAB>UNREACHABLE
parallel_probe() {
  local probe_cmd="$1"
  shift

  local max_jobs="${EXE_DEV_MAX_PARALLEL:-3}"
  local vms=("$@")
  if [ ${#vms[@]} -eq 0 ]; then
    mapfile -t vms < <(discover_vms)
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  local running=0

  for vm in "${vms[@]}"; do
    (
      local fqdn="${vm}.exe.xyz"
      local output
      output="$(fleet_ssh "$fqdn" "$probe_cmd" || true)"
      if [ -n "$output" ]; then
        printf '%s\t%s\n' "$vm" "$output" > "$tmpdir/$vm"
      else
        printf '%s\tUNREACHABLE\n' "$vm" > "$tmpdir/$vm"
      fi
    ) &
    running=$((running + 1))
    if [ "$running" -ge "$max_jobs" ]; then
      wait -n 2>/dev/null || true
      running=$((running - 1))
    fi
  done
  wait

  for vm in "${vms[@]}"; do
    if [ -f "$tmpdir/$vm" ]; then
      cat "$tmpdir/$vm"
    fi
  done

  rm -rf "$tmpdir"
}

# human_bytes <bytes>
# Convert bytes to human-readable (Gi/Mi).
human_bytes() {
  local b="$1"
  if [ "$b" -ge 1073741824 ]; then
    awk "BEGIN { printf \"%.1fGi\", $b / 1073741824 }"
  elif [ "$b" -ge 1048576 ]; then
    awk "BEGIN { printf \"%.0fMi\", $b / 1048576 }"
  else
    awk "BEGIN { printf \"%.0fKi\", $b / 1024 }"
  fi
}
