---
name: rpi
description: Preserve the RPI workflow commands create_plan, implement_plan, and research_codebase inside a portable skill. Use when the user refers to those exact command names, asks for RPI workflows, or wants the original Claude command behavior preserved as closely as possible.
---

# RPI

Use this skill for the original RPI workflows:
- `create_plan`
- `implement_plan`
- `research_codebase`

The goal of this skill is compatibility. Preserve the original command names and follow the original command instructions as closely as possible.

## Workflow Selection

- For `create_plan`, read `references/create_plan.md`
- For `implement_plan`, read `references/implement_plan.md`
- For `research_codebase`, read `references/research_codebase.md`

## Documentation Paths

Apply these path rules to all three workflows without changing their steps or document structure:

- Before writing durable research or a plan, load `recording-dev-notes` when available and applicable. Explicit per-task destination instructions take precedence. Otherwise, when that skill applies, use `skyqraft/dev-notebooks/docs` as the default documentation root, even when researching another repository. Without it, use the project's `docs/` root.
- In the paths below and in the command references, the leading `docs/` denotes that selected root, not an extra directory beneath it.
- Research goes in `docs/research/YYYY-MM-DD-<topic>/research.md`. Use a brief kebab-case topic, prefixed with the ticket identifier when relevant (for example, `2025-01-08-ENG-1478-parent-child-tracking/research.md`).
- Plans go in `docs/plans/`, with the applicable project or `recording-dev-notes` naming convention. The fallback is `YYYY-MM-DD-ENG-XXXX-description.md`, omitting the ticket identifier when absent.
- Keep other durable documentation under `docs/` too, such as ticket notes in `docs/tickets/` and devlogs in `docs/devlog/`.
- Discover existing research and plans under the selected documentation root, as well as the researched project's `docs/` when different. Read explicit input paths as given. Resolve related-document links relative to the document storing them, or use repository URLs for cross-repository links; example paths are relative to the selected documentation repository.
- Update the same research or plan artifact for follow-ups, review revisions, status changes, and implementation checkmarks. Do not create a second copy in the implementation checkout when documentation lives elsewhere.
- Research frontmatter (`repository`, `branch`, `git_commit`) and source permalinks describe the researched repository, not the repository storing the document. Gather source metadata and check push status in that source checkout.

## Maintenance

The tracked `references/*.md` files are the maintained command instructions in this repository, including their templates and examples. Their original `sources/claude-code-plugins/rpi/commands/` paths identify provenance only; that source tree is not included here. There is no RPI generator or vendor-update mapping in `scripts/update-vendor.sh`. Edit these references directly; when importing future command updates, retain the documentation-path adaptation above and in each reference. Run `python3 scripts/tests/rpi-paths.test.py` from the repository root after updates.

## Portability Notes

The original commands were written for Claude Code. When a referenced tool or primitive is Claude-specific, map it to the closest equivalent in the current agent environment while preserving intent:
- `Read tool` -> read files fully with local shell tools
- `TodoWrite` -> local task tracking or plan tracking in the current environment
- `Task agents` or specialized agents -> `spawn_agent` or equivalent local subagents when available
- `Bash()` -> local shell execution

Do not rewrite the workflow unless portability requires it. Favor preserving the exact order, tone, and expectations of the original command.

## Trigger Phrases

This skill should be used when the user says things like:
- `/create_plan`
- `/implement_plan`
- `/research_codebase`
- "use the RPI workflow"
- "follow the old Claude create_plan instructions"

## Output

When responding, keep the user-facing workflow names as:
- `create_plan`
- `implement_plan`
- `research_codebase`

If you need to explain an adaptation, keep it brief and describe only the environment-specific substitution.
