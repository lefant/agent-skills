---
name: git-resolve-merge-conflicts
description: Resolve git merge conflicts by inspecting both sides, consulting recent local project context, applying safe resolutions, and completing the merge when the resolution is clear.
---

# Git Resolve Merge Conflicts

Use this skill when the user asks for help resolving git merge conflicts.

This skill is the replacement for the old `git_resolve_merge_conflicts` command.

## Workflow

1. Identify conflicted files with git
2. Inspect the conflict markers in each file
3. Gather context from both sides of the merge:
   - `git log --stat HEAD...MERGE_HEAD -- <files>`
   - `git log --stat MERGE_HEAD...HEAD -- <files>`
4. Consult recent local context when helpful:
   - recent devlogs
   - plans
   - specs
   - ADRs
5. Resolve each file according to intent
6. Stage resolved files
7. Complete the merge commit when the resolution is clear and the user has not asked to stop short

## Resolution Heuristics

- Keep both sides when changes are complementary
- Prefer the clearer implementation when both sides solve the same problem differently
- Stay consistent on formatting-only conflicts
- Ask the user when the conflict implies contradictory logic or business rules

## Autonomy Boundary

Proceed autonomously through stage and commit when the correct merge is clear.

Pause only when ambiguity could cause a logic bug, such as:
- conflicting business rules
- incompatible data model changes
- deletions that may break dependencies

## Verification

After resolving, run the relevant tests or checks if practical.
