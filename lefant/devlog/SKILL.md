---
name: devlog
description: Write implementation devlogs that capture current session progress, learnings, related artifacts, and next steps. Use when the user asks for a devlog or WIP devlog.
---

# Devlog

Use this skill when the goal is to persist current implementation context for a later session.

This skill is the replacement for the old `devlog` command.

## Scope

Use this skill for requests like:
- "`devlog`"
- "write a devlog"
- "create a WIP devlog"
- "document this session"

## Workflow

1. Create `thoughts/shared/devlog/` if needed
2. Choose a filename using the `Europe/Stockholm` calendar date
3. Use a 3-5 word kebab-case session slug
4. If the request is work-in-progress, append `_progress.md`
5. If another entry already exists for that date and slug, append `_2`, `_3`, and so on
6. Fill in the template below using current session context

Filename patterns:
- `YYYY-MM-DD_session-slug.md`
- `YYYY-MM-DD_session-slug_progress.md`

Statuses:
- `✅ COMPLETED`
- `🔄 PARTIAL`
- `❌ BLOCKED`

The devlog should include related artifacts when known:
- `related_spec`
- `related_adr`
- `related_plan`
- `related_research`
- `related_issues`

## Template

```markdown
---
date: YYYY-MM-DD
status: ✅ COMPLETED | 🔄 PARTIAL | ❌ BLOCKED
related_spec: docs/specs/feature.md (optional)
related_adr: docs/decisions/YYYY-MM-DD_decision.md (optional)
related_plan: thoughts/shared/plans/YYYY-MM-DD_plan.md (optional)
related_research: thoughts/shared/research/YYYY-MM-DD_research.md (optional)
related_issues: [] (GitHub #123 or beads BD-042)
---

# Implementation Log - YYYY-MM-DD

**Implementation**: [what was implemented]

## Summary

One-paragraph synopsis of what was implemented, how it compared to the plan, and key outcomes achieved.

## Plan vs Reality

**What was planned:**
- [ ] Planned feature/component A

**What was actually implemented:**
- [x] Actual implementation A

## Challenges & Solutions

**Challenges encountered:**
- Problem not anticipated in plan

**Solutions found:**
- How challenges were resolved

## Learnings

- Technical insights discovered while building

## Next Steps

- [ ] Follow-up implementations needed
```

When the entry is WIP:
- use `_progress.md`
- set status to `🔄 PARTIAL`
- explicitly call out unfinished work in `## Summary`
