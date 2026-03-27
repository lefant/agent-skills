---
name: recent-context-from-git
description: Summarize recent local project context by reading recently changed documentation from git history. Use when the user asks for recent context from git or wants a compact status summary from local docs.
---

# Recent Context From Git

Use this skill when the goal is to summarize recent project context from local docs and git history.

This skill is the replacement for the old `recent_context_from_git` command.

## Documentation Roots

Prioritize these locations:
1. `thoughts/shared/devlog/`
2. `thoughts/shared/plans/`
3. `thoughts/shared/research/`
4. `docs/specs/`
5. `docs/decisions/`
6. `docs/changelog/`

## Workflow

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
