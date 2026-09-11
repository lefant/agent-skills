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

At the pinned revision, six phase prompts (`1_question`, `2_research`, `3_design`, `4_structure`, `7_implement`, and `8_pr`) and all four research-role prompts are byte-for-byte upstream copies. Only `5_plan` and `6_worktree` have local prompt edits, listed below. The router's portability and permission rules also govern how the unchanged references are executed.

Updates are reviewed manually; `scripts/update-vendor.sh` does not update this package. Preserve the source mapping, upstream license, and local adaptations when incorporating upstream changes.

## Local adaptations

- The router maps phase arguments, tools, agent roles, and fresh-context handoffs to the current host. Claude reference metadata is retained for provenance, not enforced as model selection or tool permissions.
- Human checkpoints and Research's restricted inputs remain required. Isolation is a conversation boundary, not a promise of filesystem access control.
- Worktree step 2 prepares the command rather than executing before confirmation. The copy step creates missing parent directories and checks for existing destinations before copying; the upstream command could fail for a new untracked `thoughts/qrspi/` tree.
- The Plan template uses a four-backtick outer fence so its nested code example renders correctly.
- Repository instructions, preservation of unrelated work, and shared-state authorization take precedence over upstream operational shortcuts.

For updates, compare the pinned upstream command and agent directories with the bundled references, review changes, reapply these documented adaptations, and update this revision. Do not copy the whole `.claude/` layout into the skills tree. Validate discoverability with `./scripts/check-vendor-layout.sh` from the repository root and exercise the cases in `evals/evals.json`.
