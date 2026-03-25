---
name: github-pr-review-context
description: Gather pull request review feedback and combine it with recent local project context so reviewer comments can be addressed efficiently. Use when fetching PR comments or review context.
---

# GitHub PR Review Context

Use this skill when the user wants reviewer feedback collected and organized before responding to or addressing a pull request review.

This skill is the replacement for the old `github_get_pr_comments` command.

## Dependencies

This skill depends on:
- `github-access` for GitHub API or `gh` usage
- `session-compaction` patterns for recent local documentation context

## Workflow

1. Identify the PR:
   - use a provided PR URL or number
   - otherwise detect the PR from the current branch when possible
2. Fetch:
   - PR metadata
   - top-level review summaries
   - inline review comments
   - general PR comments
3. Gather local context:
   - recent devlogs
   - active plans
   - relevant specs and ADRs
   - uncommitted documentation changes if they explain current work
4. Present a unified summary grouped by:
   - blocking or required comments
   - suggestions
   - questions
   - supporting local context

## Output Shape

```markdown
## PR #{number}: {title}
**Branch**: {head} -> {base}
**Author**: {author}
**State**: {state}

### Comments to Address
- **Blocking**
- **Suggestions**
- **Questions**

### Local Context
- Recent devlogs and plans
- Relevant specs or ADRs
- Uncommitted docs explaining current state
```

## Notes

- If no PR can be inferred from the current branch, ask the user for the PR URL or number
- Prefer concise grouping over raw comment dumps
