# QRSPI source

- Upstream: https://github.com/matanshavit/qrspi
- Revision: [8d710510643ab483708fd127bd7c9b4ca2951f48](https://github.com/matanshavit/qrspi/tree/8d710510643ab483708fd127bd7c9b4ca2951f48)
- Retrieved: 2026-09-11
- License: MIT, copyright 2026 Matan Shavit; full notice in `LICENSE`.

## Mapping

- `.claude/commands/qrspi/*.md` → `references/*.md` (eight phase prompts).
- `.claude/agents/*.md` → `references/agents/*.md` (four role prompts, not installed agents).
- `LICENSE` → `LICENSE`.

`SKILL.md` is the local portable router, following the `lefant/rpi` packaging pattern. No plugin manifest, runtime, model registration, or host-specific installation is needed.

## Ownership and fidelity

This package is maintained under `lefant/` because it is a local adaptation, not a verbatim upstream skill. The workflow and research-role prompts originate with Matan Shavit's QRSPI repository; the portable router, host compatibility guidance, and eval cases are local additions.

All eight phase prompts include the local documentation-path adaptation listed below; `5_plan` and `6_worktree` also retain their earlier local prompt edits. All four research-role prompts remain byte-for-byte copies of the pinned upstream revision. The router's portability and permission rules govern how the references are executed.

Updates are reviewed manually; `scripts/update-vendor.sh` does not update this package. Preserve the source mapping, upstream license, and local adaptations when incorporating upstream changes.

## Local adaptations

- The router maps phase arguments, tools, agent roles, and fresh-context handoffs to the current host. Claude reference metadata is retained for provenance, not enforced as model selection or tool permissions.
- Human checkpoints and Research's restricted inputs remain required. Isolation is a conversation boundary, not a promise of filesystem access control.
- Task artifacts use `docs/qrspi/<task-id>/` throughout the router, phase prompts, argument hints, handoffs, and evals. Retain this path adaptation when importing upstream updates; document names and phase contracts are unchanged.
- Worktree step 2 prepares the command rather than executing before confirmation. The copy step creates missing parent directories and checks for existing destinations before copying; the upstream command could fail for a new untracked artifact tree.
- The Plan template uses a four-backtick outer fence so its nested code example renders correctly.
- Repository instructions, preservation of unrelated work, and shared-state authorization take precedence over upstream operational shortcuts.

For updates, compare the pinned upstream command and agent directories with the bundled references, review changes, reapply these documented adaptations, and update this revision. Do not copy the whole `.claude/` layout into the skills tree. Validate discoverability with `./scripts/check-vendor-layout.sh` from the repository root and exercise the cases in `evals/evals.json`.
