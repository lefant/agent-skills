---
name: qrspi
description: Runs the portable QRSPI workflow (Question, Research, Structure, Plan, Implement), including Design, Worktree, and PR phases. Use when the user asks for QRSPI, names a /qrspi/ command, or requests its neutral-question research and staged design workflow. Not for the original RPI commands or generic planning requests.
license: MIT
---

# QRSPI

Preserve the upstream phase names, artifact contracts, and human checkpoints. Run one selected phase, not an automatic eight-phase pipeline. This is a portable skill, not a plugin or an installer for slash commands or named agents.

## Workflow Selection

Accept `/qrspi/1_question` through `/qrspi/8_pr`, their numbered names, or a phase name explicitly qualified by QRSPI (for example, “use QRSPI research”). For a new QRSPI task with no selected phase, start at Question. If the user asks to resume without naming a phase or artifact directory, ask rather than infer approval from file existence. Original `create_plan`, `implement_plan`, and `research_codebase` requests belong to RPI.

Read only the selected reference, resolving bundled paths relative to this skill's directory:

| Phase | Reference | Task artifacts to read | Output |
|---|---|---|---|
| `1_question` | `references/1_question.md` | User's task, ticket, or supplied files | `task.md`, `questions.md` |
| `2_research` | `references/2_research.md` | `questions.md` only | `research.md` |
| `3_design` | `references/3_design.md` | `task.md`, `questions.md`, `research.md` | `design.md` |
| `4_structure` | `references/4_structure.md` | `design.md`, `research.md` | `structure.md` |
| `5_plan` | `references/5_plan.md` | `structure.md`, `design.md`, `research.md` | `plan.md` |
| `6_worktree` | `references/6_worktree.md` | Check `plan.md` exists; copy task artifacts | Worktree |
| `7_implement` | `references/7_implement.md` | `plan.md`, then referenced source files | Code, verification checkboxes, phase commits |
| `8_pr` | `references/8_pr.md` | `design.md`, actual diff and commits | PR |

Task artifacts live under `thoughts/qrspi/<task-id>/` in the target repository. `$ARGUMENTS` in a phase reference means the user-supplied artifact directory, not a literal variable to execute. Question instead takes a task description, ticket, or file. Ask for missing required inputs; do not silently run prerequisite phases or read every artifact.

## Context and Human Handoffs

- Use a fresh conversation/context for each phase, carrying the phase name and artifact directory rather than the preceding conversation. Read only that phase's task inputs, plus applicable repository instructions and relevant source code.
- **Research must not run in a context that already knows the task.** If the current context includes the task, design, or implementation goal, stop and give a fresh-session handoff. If the host supports a genuinely isolated worker with no inherited conversation, it may perform the entire Research phase with only the neutral questions, repository location, and required skill instructions. Do not pass the task, ticket, branch description, or a goal-bearing conversation summary. If isolation is unavailable or uncertain, use the manual fresh-session handoff; do not claim to forget context.
- Research can read relevant source and tests, but must not open `task.md`, design/plan artifacts, or task tickets. Scope searches to code and relevant project documentation rather than searching the task artifact directory. Neutral questions reduce bias; they do not guarantee that the task cannot be inferred.
- Preserve the phase's approval stops. Question waits for edits/approval; Design asks questions and waits **before writing**; Structure waits for feedback; Worktree confirms before creation. Without a blocking-question tool, ask in the response that ends the turn and wait. Do not interpret silence as approval.
- At a phase boundary, report the artifact written and give a copyable instruction such as `Use qrspi phase 3_design with thoughts/qrspi/<task-id>/ in a fresh session.` Retain the upstream `/qrspi/...` spelling as a recognized workflow name, but do not claim this skill installs that slash command.

## Portability Notes

These adaptations govern the bundled Claude command and agent references:

- `Read`, `Edit`, `Grep`, `Glob`, and `LS` mean the host's file-reading, editing, and search tools. `TodoWrite` means available task tracking; durable QRSPI progress still lives in `plan.md` checkboxes.
- Follow applicable repository guidance (such as `AGENTS.md` or `CLAUDE.md`) and use the project's real verification commands. Reference frontmatter (`model`, `tools`, `color`, `argument-hint`) records upstream Claude metadata, not a requirement to select that model or register tools. Use the current host's configured model and capabilities.
- Named agents are research roles, not dependencies on installed agent types. Before using a role, read its matching `references/agents/<role>.md`: `codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`, or `web-search-researcher`. Pass the relevant role instructions and a bounded question to an available research/subagent tool. Use parallel workers only where the host permits it; otherwise perform the roles sequentially in the phase's context. This fallback never relaxes Research's fresh-context requirement.
- Research roles document observed facts with citations; they do not recommend changes. Resolve conflicting reports against source. Use the web research role only when external research is explicitly requested, with source URLs rather than invented `file:line` citations. If required tools are unavailable, report the gap instead of inventing findings.
- A phase instruction does not grant additional permissions. Preserve unrelated work and staged changes; stage only phase-owned changes for commits. Never overwrite an existing worktree or artifact copy without approval. Push, PR creation/update, and other shared-state changes require authorization for that action; merely reaching the PR handoff is not authorization. If publication is not authorized, prepare the PR text and ask before publishing.

## Source and Maintenance

The phase and role references are bundled so the skill works without a Claude plugin installation or a network fetch. See `SOURCE.md` for the pinned upstream revision, license, and local adaptations. Keep RPI unchanged; QRSPI is an explicitly selected alternative.
