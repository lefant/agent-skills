#!/usr/bin/env bash
# system-report.sh — comprehensive status report across exe.dev VMs
#
# Probes each VM for resources, Docker containers, git repos, and tmux sessions.
# Auto-detects available services on each host.
#
# Usage: system-report.sh [vm_name ...]
#
# Environment:
#   EXE_DEV_SSH_KEY  — path to SSH private key (optional)
#   EXE_DEV_SSH_USER — remote username (default: exedev)
#   EXE_DEV_TIMEOUT  — SSH connect timeout in seconds (default: 5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=fleet-common.sh
. "$SCRIPT_DIR/fleet-common.sh"

VM_ARGS=("$@")

# Probe outputs one record per line, fields separated by §
# Lines joined with %%% to fit parallel_probe's single-line-per-VM model
PROBE_CMD=$(cat << 'PROBE_EOF'
{
# Resources
mt=$(awk '/MemTotal/{print $2}' /proc/meminfo)
ma=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
mu=$((mt - ma))
di=$(df -h / | awk 'NR==2{print $2 "§" $3 "§" $4 "§" $5}')
up=$(uptime -s 2>/dev/null || echo unknown)
pr=$(($(ps aux 2>/dev/null | wc -l) - 1))
zm=$(ps aux 2>/dev/null | grep -c '[d]efunct' || true)
echo "R§${mt}§${mu}§${ma}§${di}§${up}§${pr}§${zm:-0}"

# Docker
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  cids=$(docker ps -q 2>/dev/null)
  if [ -n "$cids" ]; then
    for cid in $cids; do
      cn=$(docker inspect "$cid" --format '{{.Name}}' 2>/dev/null | sed 's/^\///')
      ci=$(docker inspect "$cid" --format '{{.Config.Image}}' 2>/dev/null)
      it=$(docker inspect "$cid" --format '{{.HostConfig.Init}}' 2>/dev/null || echo nil)
      echo "D§${cn}§${ci}§${it}"
    done
  else
    echo "D§none"
  fi
else
  echo "D§n/a"
fi

# Git repos
for d in ~/git/*/*/ ~/git/*/; do
  [ -d "$d/.git" ] || [ -f "$d/.git" ] || continue
  rn=$(basename "$d")
  br=$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
  rv=$(git -C "$d" rev-parse --short HEAD 2>/dev/null || echo "?")
  st=$(git -C "$d" diff --quiet 2>/dev/null && git -C "$d" diff --cached --quiet 2>/dev/null && echo clean || echo dirty)
  echo "G§${rn}§${br}§${rv}§${st}"
done 2>/dev/null

# Tmux
tx=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
[ -n "$tx" ] && echo "T§${tx}"
} | tr '\n' '~'
exit 0
PROBE_EOF
)

results="$(parallel_probe "$PROBE_CMD" "${VM_ARGS[@]}")"

if [ -z "$results" ]; then
  echo "No VMs responded." >&2
  exit 1
fi

sorted="$(echo "$results" | grep -v 'UNREACHABLE' | sort)"
unreachable="$(echo "$results" | grep 'UNREACHABLE' || true)"

# Buffer table rows for column-aligned output
_table_file="$(mktemp)"
trap 'rm -f "$_table_file"' EXIT

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "VM" "RAM used" "Disk%" "Docker" "Git" "Tmux" "Zombies" "Issues" \
  >> "$_table_file"

all_details=""

while IFS=$'\t' read -r vm raw_data; do
  [ -z "$vm" ] && continue

  mem_u_h="?" disk_pct="?" docker_summary="--" git_summary="--" tmux_summary="--"
  zombies="0" issues="" container_count=0 repo_count=0 dirty_count=0
  vm_detail=""

  IFS='~' read -ra records <<< "$raw_data"
  for rec in "${records[@]}"; do
    [ -z "$rec" ] && continue
    IFS='§' read -ra f <<< "$rec"
    case "${f[0]}" in
      R)
        mem_u_h="$(human_bytes $(( ${f[2]} * 1024 )) )"
        disk_pct="${f[7]}"
        zombies="${f[10]:-0}"
        disk_num="${disk_pct%%%}"
        [ "$zombies" -gt 5 ] 2>/dev/null && issues="${issues}${zombies} zombies; "
        [ "$disk_num" -gt 80 ] 2>/dev/null && issues="${issues}disk ${disk_pct}; "
        ;;
      D)
        if [ "${f[1]}" = "n/a" ]; then
          docker_summary="n/a"
        elif [ "${f[1]}" = "none" ]; then
          docker_summary="0"
        else
          container_count=$((container_count + 1))
          init="${f[3]:-nil}"
          vm_detail="${vm_detail}  ${f[1]}\t${f[2]} (init:${init})\n"
          [ "$init" != "true" ] && issues="${issues}init:true missing on ${f[1]}; "
        fi
        ;;
      G)
        repo_count=$((repo_count + 1))
        vm_detail="${vm_detail}  ${f[1]}\t${f[2]}@${f[3]} (${f[4]})\n"
        [ "${f[4]}" = "dirty" ] && dirty_count=$((dirty_count + 1))
        ;;
      T)
        tmux_summary="${f[1]}"
        ;;
    esac
  done

  [ "$container_count" -gt 0 ] && docker_summary="$container_count"
  if [ "$repo_count" -gt 0 ]; then
    git_summary="$repo_count"
    [ "$dirty_count" -gt 0 ] && git_summary="${git_summary} (${dirty_count} dirty)"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$vm" "$mem_u_h" "$disk_pct" "$docker_summary" "$git_summary" "$tmux_summary" "$zombies" "${issues:-ok}" \
    >> "$_table_file"

  [ -n "$vm_detail" ] && all_details="${all_details}\n### ${vm}\n${vm_detail}"

done <<< "$sorted"

while IFS=$'\t' read -r vm status; do
  [ -z "$vm" ] && continue
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$vm" "--" "--" "--" "--" "--" "--" "UNREACHABLE" \
    >> "$_table_file"
done <<< "$unreachable"

# Align and print with separator line under header
echo "## exe.dev Fleet Report"
echo ""
aligned="$(column -t -s $'\t' "$_table_file")"
header="$(echo "$aligned" | head -1)"
separator="$(echo "$header" | sed 's/./-/g')"
echo "$header"
echo "$separator"
echo "$aligned" | tail -n +2

if [ -n "$all_details" ]; then
  echo ""
  echo "## Details"
  echo -e "$all_details" | column -t -s $'\t'
fi
