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
