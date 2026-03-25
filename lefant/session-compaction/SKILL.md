---
name: session-compaction
description: Capture recent work context for future sessions by summarizing recent docs, writing devlogs, and generating handover prompts. Use for devlog, handover, or recent-context-from-git style tasks.
---

# Session Compaction

Use this skill when the goal is to preserve working context, summarize recent project documentation, or prepare a clean handoff into a later session.

This skill covers three closely related workflows:
- `recent_context_from_git`
- `devlog`
- `handover`

## Scope

Use this skill for requests like:
- "`recent_context_from_git`"
- "`devlog`"
- "`handover`"
- "write a devlog"
- "create a WIP devlog"
- "summarize recent context from git"
- "generate a handover prompt"
- "what should the next session know?"

## Documentation Roots

Prioritize these locations:
1. `thoughts/shared/devlog/`
2. `thoughts/shared/plans/`
3. `thoughts/shared/research/`
4. `docs/specs/`
5. `docs/decisions/`
6. `docs/changelog/`

## Recent Context Workflow

When asked to gather recent context:
1. Query recent git history for the documentation roots above
2. Read the most relevant recent files, prioritizing devlogs and plans
3. Return a compact summary with:
   - in-progress work
   - recently completed work
   - key supporting specs, ADRs, or research
   - suggested next steps

Prefer commands equivalent to:

```bash
git log --name-only --no-commit-id --pretty=format: \
  -- 'thoughts/shared/research/*.md' \
     'thoughts/shared/plans/*.md' \
     'thoughts/shared/devlog/*.md' \
     'docs/specs/*.md' \
     'docs/decisions/*.md' \
     'docs/changelog/*.md'
```

Then deduplicate, prioritize by recency, and read the most relevant files.

## Devlog Workflow

When asked to create a devlog:
1. Create `thoughts/shared/devlog/` if needed
2. Choose a filename using the `Europe/Stockholm` calendar date
3. Use a 3-5 word kebab-case session slug
4. If the request is work-in-progress, append `_progress.md`
5. If another entry already exists for that date and slug, append `_2`, `_3`, and so on
6. Fill in the devlog template below using current session context

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

## Devlog Template

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

## Handover Workflow

When asked to generate a handover:
1. Gather recent context first
2. Ensure there is a current `_progress.md` devlog if work is still in progress
3. Identify the next task from plans, issues, or the conversation
4. Produce a concise handover prompt with references

Keep the handover description to five sentences or fewer.

Use this output shape:

```text
HANDOVER PROMPT

[Short description of current work and state]

Context:
- Devlog: thoughts/shared/devlog/YYYY-MM-DD_session_progress.md
- Plan: thoughts/shared/plans/YYYY-MM-DD_plan.md
- Spec: docs/specs/feature.md
- ADR: docs/decisions/YYYY-MM-DD_decision.md
- Issues: BD-042, #123

Next: [specific next task]
```

## Writing Guidance

- Prefer concrete references over general summaries
- Persist context while it is fresh
- Be honest about gaps, blockers, and deviations
- Do not invent next steps that are not supported by docs or conversation context
