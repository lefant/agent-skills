# Spec Quick Reference

## Required layout

```text
skill-name/
├── SKILL.md
├── scripts/      # optional
├── references/   # optional
├── assets/       # optional
└── ...
```

## `SKILL.md` frontmatter

Required:

- `name`
- `description`

Optional:

- `license`
- `compatibility`
- `metadata`
- `allowed-tools`

## `name` rules

- 1-64 characters
- lowercase letters, numbers, and hyphens only
- must not start or end with `-`
- should not contain consecutive hyphens
- should match the parent directory name exactly

## `description` rules

- 1-1024 characters
- non-empty
- should say both what the skill does and when to use it
- should use user-intent language that helps triggering

## Recommended file roles

- `SKILL.md` — core instructions loaded on trigger
- `references/` — detailed docs loaded on demand
- `scripts/` — executable helpers for repeated or deterministic tasks
- `assets/` — templates, fixtures, static examples

## Progressive disclosure

Recommended loading discipline:

1. metadata always visible
2. `SKILL.md` body loaded on activation
3. bundled resources loaded only when needed

Practical consequences:

- keep `SKILL.md` under about 500 lines when possible
- move large detail into `references/`
- keep reference hops shallow
- when pointing to a file, say when to read it

## Relative paths

Use relative paths from the skill root.

Good:

- `references/authoring-guide.md`
- `references/description-optimization.md`
- `assets/skill-template.md`

Avoid:

- absolute paths
- repo-specific paths outside the skill
- deep chains of nested references that require many hops to follow

## Minimal skeleton

```markdown
---
name: my-skill
description: Use when the user needs X. Covers Y and Z.
---

# My Skill

## When this skill applies
narrow scope statement

## Default workflow
ordered steps

## Gotchas
concrete surprises

## Validation
how to verify success

## Read next
- `references/<detail-file>.md` when condition X happens
```

## Practical authoring rules

- Put trigger logic in the `description`, not hidden in the body.
- Keep the main body focused on the common case.
- Put detailed variants in `references/`.
- If the same shell or parsing logic keeps being reinvented, move it into `scripts/`.
- If output shape matters, store a template in `assets/` or inline it if short.
- Keep the package self-contained so it can be reused outside the original repo.

## Validation checklist

Before shipping a skill, confirm:

- frontmatter parses
- directory name matches `name`
- description stays under 1024 chars
- all referenced files exist
- no referenced authoring docs live outside the skill
- main body does not duplicate whole reference files