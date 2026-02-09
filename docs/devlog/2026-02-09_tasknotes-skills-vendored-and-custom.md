---
date: 2026-02-09
status: ✅ COMPLETED
---

# Implementation Log – 2026-02-09

**Implementation**: Vendored ArtemXTech/personal-os-skills tasknotes skill and created custom lefant/tasknotes skill for direct file-based task creation

## Summary

Added two TaskNotes skills to the agent-skills repo. First, vendored the ArtemXTech/personal-os-skills tasknotes skill which provides a Python CLI (`tasks.py`) that talks to the TaskNotes HTTP API. Second, researched the callumalpass/tasknotes Obsidian plugin source code in depth and created a custom `lefant/tasknotes` skill that creates tasks by writing markdown files directly to the vault -- no HTTP API, no Python, no CLI required.

## What Was Implemented

- [x] Vendored `ArtemXTech/personal-os-skills` tasknotes skill to `vendor/ArtemXTech/tasknotes/`
- [x] Added `SKILL.md` and `scripts/tasks.py` from upstream
- [x] Updated `vendor/README.md` with source entry
- [x] Updated `scripts/update-vendor.sh` with fetch entry
- [x] Researched callumalpass/tasknotes plugin source code (types.ts, defaults.ts, TaskService.ts, FieldMapper.ts, filenameGenerator.ts)
- [x] Created custom `lefant/tasknotes/SKILL.md` for direct file creation
- [x] Updated `README.md` with new custom skill entry

## Key Research Findings

The TaskNotes plugin stores tasks as plain markdown files with YAML frontmatter in a configurable folder (default: `TaskNotes/Tasks/`). Key details from source code analysis:

- **Task identification**: Two methods -- tag-based (default, needs `tags: [task]`) or property-based (custom frontmatter key/value)
- **Default statuses**: none, open, in-progress, done (only "done" has `isCompleted: true`)
- **Default priorities**: none (0), low (1), normal (2), high (3)
- **Field mapping**: All property names are remappable via `fieldMapping` in plugin settings (`data.json`)
- **Filename**: Default is `storeTitleInFilename: true` using sanitized title; also supports zettel, timestamp, custom templates
- **Config location**: `<vault>/.obsidian/plugins/tasknotes/data.json` contains all settings
- **No database**: Files are the source of truth -- "Tasks are just Markdown files with YAML"

## Challenges & Solutions

**Challenge**: The vendored skill's `tasks.py` has a `VAULT_ROOT` path that walks 4 levels up from the script. This is fine for the original repo layout but may not match our vendor directory structure.

**Solution**: Documented as-is since the vendored skill is meant to be used with the HTTP API approach. The custom skill avoids this entirely by writing files directly.

**Challenge**: TaskNotes has extensive field mapping customization. A skill that hardcodes property names would break for users who remapped fields.

**Solution**: The custom skill instructs agents to read `data.json` to discover the user's actual field mapping, status values, and priority values before creating tasks.

## Learnings

- TaskNotes is remarkably well-architected for external tool integration -- the "files are the API" approach means any tool that can write markdown can create tasks
- The plugin's `FieldMapper` system decouples internal names from YAML property names, so skills must respect user configuration
- Reading the source code directly (types.ts, defaults.ts) was far more reliable than web documentation for understanding the exact schema and defaults
- The custom skill approach (direct file writes) is strictly superior to the API approach for agent use cases: no runtime deps, works offline, works even when Obsidian is closed

## Vendored vs Custom Skill Comparison

| Aspect | Vendored (ArtemXTech) | Custom (lefant) |
|--------|----------------------|-----------------|
| Approach | HTTP API via Python CLI | Direct file writes |
| Dependencies | Python 3.11+, requests, python-dotenv, uv | None |
| Requires Obsidian running | Yes (HTTP API must be enabled) | No |
| Config awareness | Reads from `.env` file | Reads from `data.json` |
| Field mapping support | No (hardcoded property names) | Yes (reads fieldMapping) |
