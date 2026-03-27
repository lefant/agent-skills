# Fix: Pi skill name compatibility

**Date:** 2026-03-27
**Target:** lefant-ctrl
**Repo:** agent-skills

## Issue

Pi reported startup conflicts for multiple shared skills:

- `vendor/dz0ny/devenv/SKILL.md` used `name: devenv-migration` while the installed skill directory is `devenv`
- several in-house `lefant/` skills used underscores in both the directory name and `name:` field, but Pi only accepts lowercase letters, digits, and hyphens

## Fix

- Changed `vendor/dz0ny/devenv/SKILL.md` to `name: devenv`
- Updated `vendor/dz0ny/devenv/README.md` to match the canonical directory name
- Renamed these in-house skill directories to hyphenated names and updated their `name:` fields:
  - `atomically-land`
  - `git-resolve-merge-conflicts`
  - `github-get-pr-comments`
  - `recent-context-from-git`
- Updated cross-references in `README.md` and `lefant/handover/SKILL.md`

## Verification

- Rebuilt `~/.agents/skills` from the canonical `sources/agent-skills` tree using `toolbox-setup-hook.sh`
- Verified generated skill directory names match `name:` fields
- Restarted Pi in tmux and confirmed the previous `devenv`, `tavily-search`, and underscore-name conflicts were removed

## Follow-up

- Update any downstream subtree copies or packaged skill bundles that still carry stale skill metadata
