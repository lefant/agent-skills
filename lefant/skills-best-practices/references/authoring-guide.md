# Authoring Guide

## Start from real expertise

Do not write a skill from generic "best practices" alone.

Use real material:

- transcripts from successful runs
- corrections made during those runs
- project docs and runbooks
- API specs, schemas, and config
- bug fixes, incident notes, and review comments
- existing skills that already work

The point of the skill is to preserve concrete defaults and gotchas that the base model would likely miss.

## Capture what to keep

When extracting from real work, pull out:

- successful step sequence
- decision points
- default tools or commands
- failure patterns
- validation steps
- output shape
- environment assumptions

If the agent kept reinventing the same helper script or shell pipeline, that is a sign to bundle it.

## Scope like a function

A skill should cover one coherent unit of work.

Too narrow:

- multiple overlapping skills need to load for one ordinary task
- the agent bounces between tiny skills

Too broad:

- the description becomes fuzzy
- unrelated instructions load together
- triggering gets noisy

Use the body to make boundaries explicit:

- what this skill handles by default
- what it does not handle
- where to hand off if the task moves outside scope

## Spend context carefully

Skills use a layered loading model:

1. `name` + `description` are always visible
2. `SKILL.md` loads when the skill triggers
3. `references/`, `scripts/`, and `assets/` load only when needed

This means:

- keep `SKILL.md` lean
- avoid teaching general concepts the model already knows
- include only information the model would likely miss without help
- move detailed variants and deep references out of the main body

A useful rule of thumb:

- keep `SKILL.md` under roughly 500 lines when possible
- if it grows large, split variant-specific material into `references/`
- for large reference files, tell the agent exactly when to read them

## Put trigger info in the description

The frontmatter `description` is the main trigger surface.

A strong description says:

- what the skill does
- when to use it
- what user intents should map to it
- near-miss boundary hints when another skill might compete

Write around user intent, not implementation details.

Weak:

- `description: helps with APIs`

Better:

- `description: Use for OAuth-backed CRM API workflows including customer lookup, contact updates, and export reconciliation. Trigger when the user needs CRM reads or guarded write actions, even if they ask in business language instead of naming the API directly.`

## Prefer defaults over menus

Pick a default path.

Bad skill behavior:

- presents 4 equal tools
- presents 3 equal output formats
- leaves the model to choose from a menu every run

Better:

- pick the default tool
- pick the default workflow
- mention fallback branches briefly
- explain when to switch

## Explain why, not just what

Rigid instructions have their place, but most skill content works better when the model understands the reason behind the rule.

Instead of:

- `ALWAYS inspect the schema first.`

Prefer:

- `Inspect the schema first so field names and types come from the source of truth rather than assumption. This avoids drift and makes later validation easier.`

## High-value patterns

### Gotchas

Use a `Gotchas` section for concrete surprises:

- naming mismatches across systems
- hidden soft-delete filters
- misleading health checks
- required env vars or path quirks
- provider-specific field semantics

### Output templates

When output structure matters, show a concrete template.

### Checklists

Use explicit checklists for multi-step tasks with ordering constraints.

### Validation loops

Tell the agent to run a validator, inspect failures, fix them, and re-run.

### Plan-validate-execute

For risky or batch operations, require an intermediate plan and a validation step before execution.

## Self-contained packaging

A reusable skill should not depend on invisible context from the extraction session.

Bundle inside the skill anything that is needed repeatedly:

- reference docs
- templates
- sample schemas
- validation scripts
- parsing helpers

It is fine for the skill to act on external project files. It is not fine for the skill instructions themselves to require browsing back into a specific repo's hidden docs just to understand how to operate.

## What to cut

Remove:

- generic filler the model already knows
- repeated prose that appears in both `SKILL.md` and `references/`
- branches that rarely matter and confuse the default workflow
- instructions that transcripts show are wasting time

A shorter skill with sharper defaults is usually stronger than a longer skill with broad but shallow advice.