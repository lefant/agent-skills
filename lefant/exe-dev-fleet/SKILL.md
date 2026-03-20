---
name: exe-dev-fleet
description: Fleet management for exe.dev VMs. Use when the user asks for system status, resource overview, fleet health, or VM inventory across exe.dev machines. Provides scripts for parallel probing of memory, disk, Docker, git repos, and process health.
---

# exe.dev Fleet Management

Parallel SSH probing and reporting across exe.dev VM fleets.

## Prerequisites

- SSH access to exe.dev VMs (key configured in `~/.ssh/config` or via `EXE_DEV_SSH_KEY`)
- `jq` installed locally (for parsing `ssh exe.dev ls --json`)
- VMs accessible as `<vm-name>.exe.xyz`

## Scripts

All scripts are in the `scripts/` directory relative to this skill.

### `system-resources.sh`

Fast resource overview (~10s). Probes all VMs for memory, disk, uptime, processes, and zombies.

```bash
# Use default SSH key from config/agent
scripts/system-resources.sh

# With explicit SSH key
EXE_DEV_SSH_KEY=~/.ssh/my-key scripts/system-resources.sh

# TSV output for machine parsing
scripts/system-resources.sh --tsv
```

Outputs a markdown table sorted by RAM used (descending) with summary totals and alerts for zombies > 5 or disk > 80%.

### `system-report.sh`

Comprehensive status report (~15s). Auto-detects and reports:

- **Resources**: RAM, disk, uptime, process/zombie counts
- **Docker**: running containers, images, `init:true` status
- **Git repos**: branch, revision, clean/dirty status
- **Tmux**: active sessions

```bash
# All VMs
scripts/system-report.sh

# Specific VMs only
scripts/system-report.sh lefant-ctrl lefant-memory
```

Outputs a summary table plus per-host detail sections for Docker containers and git repos.

### `fleet-common.sh`

Shared library sourced by the other scripts. Provides:

- `fleet_ssh <host> <cmd>` — SSH to a single VM
- `discover_vms` — list all VM names via exe.dev API
- `parallel_probe <cmd> [vms...]` — run command on VMs in parallel (max 3 concurrent)
- `human_bytes <n>` — convert bytes to human-readable

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `EXE_DEV_SSH_KEY` | *(ssh-agent/config)* | Path to SSH private key |
| `EXE_DEV_SSH_USER` | `exedev` | Remote SSH username |
| `EXE_DEV_TIMEOUT` | `5` | SSH connect timeout (seconds) |
| `EXE_DEV_MAX_PARALLEL` | `3` | Max concurrent SSH connections |

## Usage with Claude Code

When the user asks for fleet status or system overview:

1. Locate scripts: they are in this skill's `scripts/` directory
2. Run the appropriate script via Bash tool
3. Present the markdown output directly — it's already formatted
4. Add commentary on any alerts or issues found
5. Suggest actions for problems (high disk, zombies, missing init:true, dirty repos)
