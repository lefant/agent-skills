---
name: your-skill-name
description: Use when the user needs [job to be done]. Covers [main scope]. Trigger even when the user describes the need indirectly as [common phrasing].
---

# Your Skill Name

## Scope

Use this skill for:

- primary task class
- closely related subtask
- guarded variant if applicable

Do not use this skill for:

- adjacent task class owned elsewhere
- unrelated admin or setup work

## Default workflow

1. Inspect the source of truth first.
2. Choose the default path or tool.
3. Perform the task.
4. Validate the result.
5. Return the required output format.

## Defaults

- default tool:
- default script:
- default output format:
- fallback path and when to use it:

## Gotchas

- surprising mismatch or hidden filter
- environment or auth quirk
- field semantics or naming trap

## Validation

Before finishing:

- run:
- verify:
- if validation fails:

## Output

Use this shape unless the user asks for something else:

```markdown
# [title]
## Summary
## Findings
## Actions taken
## Next steps
```

## Read next

- `references/[detail-file].md` when [condition]
- `references/[variant-file].md` when [condition]

## Available scripts

- `scripts/[helper].py` — [purpose]

## Notes for future refinement

After live runs, extract:

- corrections that recur
- wasted work that should be cut
- repeated helper logic that should move into `scripts/`
- better trigger phrasing for the description