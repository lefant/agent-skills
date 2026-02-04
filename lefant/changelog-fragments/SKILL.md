---
name: changelog-fragments
description: Create and manage changelog fragments to track changes without merge conflicts. Each change gets its own file for parallel development.
---

# CHANGELOG Fragments Skill

Use this skill when creating or working with CHANGELOG fragments. Fragments are permanent records of changes, stored in `./docs/changelog/`.

## Purpose

Changelog fragments prevent merge conflicts when multiple branches are developed in parallel. Each change gets its own file that stays as permanent documentation.

## Directory Layout

Fragments are stored in `./docs/changelog/` at the project root. Create this directory on demand when writing the first fragment.

## File Naming Convention

`YYYY-MM-DD_brief-description.md`

Examples:
- `2025-11-19_oauth-token-refresh.md`
- `2025-11-05_sync-database-tracking.md`
- `2025-12-03_hydration-error-fix.md`

## Template

See `template.md` in this skill directory for the fragment format.

## Fragment Types

- **feature**: New features or enhancements
- **fix**: Bug fixes
- **chore**: Maintenance tasks, dependency updates
- **docs**: Documentation changes
- **refactor**: Code refactoring without behavior changes
- **test**: Test additions or improvements
- **perf**: Performance improvements

## When to Create a Fragment

Create a fragment for:
- Completing a planned feature or fix
- Making a breaking change
- Significant refactoring or architecture changes
- Important bug fixes
- Documentation improvements that affect users

Skip fragments for:
- Work-in-progress commits
- Typo fixes in comments
- Small documentation tweaks
- Personal experiments

## Cross-Referencing

Fragments should link to related documentation. Use the frontmatter fields:

| Field | Links to |
|-------|----------|
| `related_adr` | Architecture decision in `docs/decisions/` |
| `related_spec` | Feature spec in `docs/specs/` |
| `related_devlog` | Implementation devlog in `thoughts/shared/devlog/` |
| `related_plan` | Implementation plan in `thoughts/shared/plans/` |
| `related_research` | Research doc in `thoughts/shared/research/` |
| `related_issues` | GitHub issues `[#123]` or beads `[BD-042]` |
| `related_prs` | Pull requests `[#456]` |

Example:
```yaml
---
date: 2025-11-20
type: feature
related_adr: docs/decisions/2025-11-18_use-inngest-for-workflows.md
related_spec: docs/specs/sync-status-tracking.md
related_devlog: thoughts/shared/devlog/2025-11-20_inngest-integration.md
related_issues: [#49, BD-042]
---
```

## Writing Guidelines

1. **Brief summary**: 1-3 sentences, what changed and why it matters
2. **User-facing**: Focus on impact, not implementation details
3. **Optional details**: Add bullet points for complex changes

## Browsing Fragments

```bash
# List all fragments chronologically
ls -1 docs/changelog/

# Find fragments about a topic
grep -l "oauth" docs/changelog/*.md

# See all fragments of a type
grep "^type: feature" docs/changelog/*.md
```

## Creating a Fragment

Use the `/changelog_create` command:
```
/changelog_create "OAuth token refresh implementation"
```

## Skill Activation

This skill activates when:
- Completing implementation work
- User runs `/devlog` (prompt to create fragment)
- Landing changes that should be documented
