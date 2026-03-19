# Fix: tavily-search skill name mismatch

**Date:** 2026-03-19
**Target:** lefant-toolbox-nix.exe.xyz
**Repo:** agent-skills

## Issue

Pi coding agent reported skill conflict errors:

```
[Skill conflicts]
  auto (user) ~/.pi/agent/skills/tavily-search/SKILL.md
    name "tavily" does not match parent directory "tavily-search"
  auto (user) ~/.agents/skills/tavily-search/SKILL.md
    name "tavily" does not match parent directory "tavily-search"
```

## Fix

Changed `name: tavily` to `name: tavily-search` in `vendor/openclaw/tavily-search/SKILL.md` to match the directory name.

Committed and pushed to agent-skills repo (3b8ed5d).

## Follow-up

Re-sync agent-skills on lefant-toolbox-nix to pick up the fix.
