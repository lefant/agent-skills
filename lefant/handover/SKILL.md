---
name: handover
description: Generate a concise handover prompt for the next session, ensuring current work context is persisted and the next task is clear.
---

# Handover

Use this skill when the user wants a resume prompt for a future session.

This skill is the replacement for the old `handover` command.

## Workflow

1. Gather recent context first using `recent_context_from_git`
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
