# lefant/agent-skills

Curated skills for AI coding agents (Claude Code, Codex, OpenCode).

## Structure

- `lefant/` - Custom skills developed in-house
- `vendor/` - Vendored skills from upstream repositories (reviewed for security)

## Usage

### With skills CLI
```bash
skills add /path/to/agent-skills --skill '*' -g -y -a claude-code -a codex -a opencode
```

### In Docker
Cloned to `/opt/lefant-agent-skills` and symlinked via entrypoint.

## Updating Vendored Skills

```bash
./scripts/update-vendor.sh
```
Then review changes before committing.

## Skills Included

### Custom Skills (`lefant/`)

| Skill | Description |
|-------|-------------|
| `github-access` | Access GitHub repositories via gh CLI or REST API |
| `sentry` | Fetch and analyze Sentry issues, events, and logs |
| `architecture-decision-records` | Create and manage ADRs |
| `changelog-fragments` | Maintain changelog fragments for conflict-free history |
| `feature-specs` | Document feature requirements and scenarios |
| `mermaid-diagrams` | Create hierarchical Mermaid diagrams |
| `test-analyzer` | Analyze CTRF test reports with jq |
| `youtube-transcript` | Fetch YouTube video transcripts |
| `tasknotes` | Create and manage Obsidian tasks via TaskNotes (direct file creation) |

### Vendored Skills (`vendor/`)

See `vendor/README.md` for sources and update process.
