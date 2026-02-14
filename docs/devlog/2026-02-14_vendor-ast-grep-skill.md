---
date: 2026-02-14
status: ✅ COMPLETED
---

# Implementation Log – 2026-02-14

**Implementation**: Vendor ast-grep agent skill from ast-grep/agent-skill

## Summary

Added the ast-grep agent skill from [ast-grep/agent-skill](https://github.com/ast-grep/agent-skill) to the vendor directory. The skill teaches agents how to use ast-grep for AST-based structural code search — finding code patterns by structure rather than text matching. Straightforward vendor addition following established patterns.

## What was implemented

- [x] Cloned `ast-grep/agent-skill` repo and copied skill files to `vendor/ast-grep/ast-grep/`
- [x] `SKILL.md` — main skill file covering workflow, CLI commands, rule writing tips, common use cases
- [x] `references/rule_reference.md` — comprehensive rule syntax reference (atomic, relational, composite rules, metavariables)
- [x] Added `fetch_skill` entry in `scripts/update-vendor.sh`
- [x] Added source entry in `vendor/README.md` table

## Challenges & Solutions

- **WebFetch couldn't return raw file content** — the tool summarizes instead of returning verbatim content. Solved by cloning the repo directly with `git clone --depth 1` to get exact files.
- **Finding the repo URL** — the skills.sh URL format `ast-grep/agent-skill/ast-grep` maps to GitHub repo `ast-grep/agent-skill` with skill at path `ast-grep/skills/ast-grep/`.

## Learnings

- For vendoring skills, always clone the repo directly rather than trying to fetch raw files via WebFetch — it's faster and gives exact content.
- The skill path in the repo (`ast-grep/skills/ast-grep`) differs from the vendor target path (`vendor/ast-grep/ast-grep/`) — the `fetch_skill` function handles this mapping.
- Skills.sh URL pattern: `skills.sh/{org}/{repo}/{skill-name}` → GitHub `github.com/{org}/{repo}` with skill at `{skill-name}/skills/{skill-name}/`.
