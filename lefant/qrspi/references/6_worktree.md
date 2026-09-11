---
description: Create an isolated git worktree for implementation
argument-hint: "thoughts/qrspi/<id>/"
---

# Worktree — Isolate the Implementation

Create a git worktree so implementation happens on an isolated branch without affecting your main working tree.

## Input

The artifact directory is `$ARGUMENTS`.

## Process

1. **Determine identifiers** from the artifact directory name:
   - Branch name: derive from the directory name (e.g., `ENG-1234-description` or `2026-03-29-new-feature`)
   - Repo name: detect from `basename $(git rev-parse --show-toplevel)`
   - Worktree path: `~/wt/<repo-name>/<branch-name>`

2. **Prepare the worktree command without executing it.** First verify that `plan.md` exists and inspect the branch and destination for collisions. Do not reuse or overwrite an existing branch or worktree without agreement.
   ```
   git worktree add ~/wt/<repo-name>/<branch-name> -b <branch-name>
   ```

3. **Confirm with the user** before executing:
   ```
   Ready to create worktree:

   Worktree: ~/wt/<repo-name>/<branch-name>
   Branch: <branch-name>
   Plan: $ARGUMENTS/plan.md

   To implement, run from the worktree:
     /qrspi/7_implement $ARGUMENTS

   Proceed?
   ```

4. **Create the worktree** after user confirms.

5. **Copy QRSPI artifacts** to the worktree. Untracked files from the main tree do not appear in worktrees. Resolve the source directory and its repository-relative path, then create the missing parent directories for that path inside the new worktree. Copy the source directory to that destination, quoting paths. If the destination already exists (for example, artifacts are tracked), compare it first: leave identical files alone and ask before replacing differing files. Verify that the destination's `plan.md` exists and the artifacts match the source. Give the user the artifact path inside the new worktree, not an absolute path into the original checkout.

## Output

- Git worktree created at `~/wt/<repo-name>/<branch-name>`
- QRSPI artifacts copied to the worktree
- Tell the user the worktree path and how to start implementation

## Rules

- Always confirm before creating the worktree.
- Worktrees do not share untracked files with the main tree. Always copy the artifact directory after creating the worktree.
- Do not start implementation. That's a separate phase with a separate context window.

## When to Go Back

If the plan doesn't exist yet at `$ARGUMENTS/plan.md`, tell the user to run `/qrspi/5_plan` first.
