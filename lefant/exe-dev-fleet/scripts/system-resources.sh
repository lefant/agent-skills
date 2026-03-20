#!/usr/bin/env bash
# system-resources.sh — resource usage overview across all exe.dev VMs
#
# Probes each VM in parallel for memory, disk, uptime, processes, and zombies.
# Outputs a markdown table sorted by RAM used (descending).
#
# Usage: system-resources.sh [--tsv]
#
# Environment:
#   EXE_DEV_SSH_KEY  — path to SSH private key (optional)
#   EXE_DEV_SSH_USER — remote username (default: exedev)
#   EXE_DEV_TIMEOUT  — SSH connect timeout in seconds (default: 5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=fleet-common.sh
. "$SCRIPT_DIR/fleet-common.sh"

OUTPUT_MODE="${1:-markdown}"

# Probe script is written to a temp file to avoid quoting hell.
PROBE_SCRIPT="$(mktemp)"
trap 'rm -f "$PROBE_SCRIPT"' EXIT

cat > "$PROBE_SCRIPT" << 'PROBE_EOF'
mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
mem_avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
mem_used=$((mem_total - mem_avail))
disk=$(df -h / | awk 'NR==2{printf "%s\t%s\t%s\t%s", $2, $3, $4, $5}')
up=$(uptime -s 2>/dev/null || echo unknown)
procs=$(($(ps aux 2>/dev/null | wc -l) - 1))
zombies=$(ps aux 2>/dev/null | grep -c '[d]efunct' || echo 0)
printf "%d\t%d\t%d\t%s\t%s\t%d\t%d" "$mem_total" "$mem_used" "$mem_avail" "$disk" "$up" "$procs" "$zombies"
PROBE_EOF

PROBE_CMD="$(cat "$PROBE_SCRIPT")"

# Collect results
results="$(parallel_probe "$PROBE_CMD")"

if [ -z "$results" ]; then
  echo "No VMs responded." >&2
  exit 1
fi

if [ "$OUTPUT_MODE" = "--tsv" ]; then
  printf "vm\tmem_total_kb\tmem_used_kb\tmem_avail_kb\tdisk_total\tdisk_used\tdisk_avail\tdisk_pct\tup_since\tprocs\tzombies\n"
  echo "$results" | sort -t$'\t' -k3 -nr
  exit 0
fi

# Markdown output
total_vms=0
total_reachable=0
total_mem_used=0
total_procs=0
total_zombies=0

# Parse and sort by mem_used descending
sorted="$(echo "$results" | grep -v 'UNREACHABLE' | sort -t$'\t' -k3 -nr)"
unreachable="$(echo "$results" | grep 'UNREACHABLE' || true)"

# Buffer table rows for column-aligned output
_table_file="$(mktemp)"
trap 'rm -f "$PROBE_SCRIPT" "$_table_file"' EXIT

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "VM" "RAM used" "RAM avail" "RAM total" "Disk used" "Disk avail" "Disk%" "Procs" "Zombies" "Up since" "Issues" \
  >> "$_table_file"

while IFS=$'\t' read -r vm mem_t mem_u mem_a disk_t disk_u disk_a disk_pct up procs zombies; do
  [ -z "$vm" ] && continue

  mem_t_h="$(human_bytes $((mem_t * 1024)))"
  mem_u_h="$(human_bytes $((mem_u * 1024)))"
  mem_a_h="$(human_bytes $((mem_a * 1024)))"

  issues=""
  if [ "$zombies" -gt 5 ] 2>/dev/null; then
    issues="${issues}${zombies} zombies; "
  fi
  disk_num="${disk_pct%%%}"
  if [ "$disk_num" -gt 80 ] 2>/dev/null; then
    issues="${issues}disk ${disk_pct}; "
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$vm" "$mem_u_h" "$mem_a_h" "$mem_t_h" "$disk_u" "$disk_a" "$disk_pct" "$procs" "$zombies" "$up" "${issues:-ok}" \
    >> "$_table_file"

  total_vms=$((total_vms + 1))
  total_reachable=$((total_reachable + 1))
  total_mem_used=$((total_mem_used + mem_u))
  total_procs=$((total_procs + procs))
  total_zombies=$((total_zombies + zombies))
done <<< "$sorted"

while IFS=$'\t' read -r vm status; do
  [ -z "$vm" ] && continue
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$vm" "--" "--" "--" "--" "--" "--" "--" "--" "--" "UNREACHABLE" \
    >> "$_table_file"
  total_vms=$((total_vms + 1))
done <<< "$unreachable"

# Align and print with separator line under header
echo "## exe.dev Fleet Resources"
echo ""
aligned="$(column -t -s $'\t' "$_table_file")"
header="$(echo "$aligned" | head -1)"
separator="$(echo "$header" | sed 's/./-/g')"
echo "$header"
echo "$separator"
echo "$aligned" | tail -n +2
echo ""
echo "${total_reachable}/${total_vms} VMs reachable | RAM used: $(human_bytes $((total_mem_used * 1024))) | Procs: ${total_procs} | Zombies: ${total_zombies}"
