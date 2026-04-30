---
title: Package Skill-Required Reference Docs Inside the Skill
date: 2026-04-29
category: documentation-gaps
module: skills-best-practices
problem_type: documentation_gap
component: documentation
severity: medium
applies_when:
  - "Importing upstream reference docs that a skill needs at runtime"
  - "Adapting docs from another repository into this agent-skills layout"
  - "Avoiding duplicate installable skill packages or nested upstream skills/ layouts"
symptoms:
  - "A skill references repo-level docs that will not ship with the installed skill"
  - "Imported upstream docs duplicate an existing vendored installable skill"
  - "Reference material lands under docs/vendor/... with an upstream skills/ layout"
root_cause: inadequate_documentation
resolution_type: documentation_update
tags: [skills-best-practices, upstream-docs, packaging, references, vendor]
---

# Package Skill-Required Reference Docs Inside the Skill

## Context

The Agent Skills authoring reference docs were imported to improve this repository's `skills-best-practices` guidance. The initial source material included upstream documentation and reference skill content, but this repo has two separate concerns:

1. **Installable skills** live under `lefant/<skill>/` or `vendor/<source>/<skill>/`.
2. **Skill-required reference material** must live inside the skill package that needs it, otherwise deployed agents will not receive it.

The final implementation kept `vendor/anthropics/skill-creator/` as the installable upstream Anthropic skill package and placed the public Agent Skills docs snapshot under:

```text
lefant/skills-best-practices/references/upstream/agentskills/
```

Session history did not surface prior related attempts for this repo in the last seven days.

## Guidance

When importing upstream docs for a skill, decide whether the imported content is an installable skill or runtime reference material.

- If it is an installable skill, vendor it as `vendor/<source>/<skill>/` and register it in `scripts/update-vendor.sh`.
- If it is reference material that a local skill needs while running, place it under that skill's own `references/`, `scripts/`, or `assets/` tree.
- Do not put skill-required docs only under repo-level `docs/`; those files may be absent after skill installation.
- Do not copy a second installable skill package under `docs/vendor/...`; that duplicates the real vendor package and can reintroduce nested upstream `skills/` layouts.

For `skills-best-practices`, the refreshable upstream snapshot lives inside the skill:

```text
lefant/skills-best-practices/
├── SKILL.md
├── references/
│   ├── update-upstream-docs.md
│   └── upstream/agentskills/
└── scripts/
    └── update-agentskills-docs.sh
```

The skill entry point points agents to the bundled docs only when needed:

```md
- `references/update-upstream-docs.md` — refreshing bundled upstream Agent Skills docs
- `references/upstream/agentskills/` — vendored public Agent Skills docs; read specific files only when the distilled local references are insufficient
```

`references/update-upstream-docs.md` documents how to refresh the snapshot, and `scripts/update-agentskills-docs.sh` performs the refresh from the public `agentskills/agentskills` repository plus `https://agentskills.io/llms.txt`.

Keep a repo-level source map for humans and maintainers, but do not make the skill depend on it:

```text
docs/reference/agent-skill-authoring-best-practices.md
docs/reference/agent-skill-source-map.md
```

These files explain where guidance came from and how it relates to existing local and vendored skills. They are useful for maintenance, but the deployed `skills-best-practices` package is self-contained without them.

## Why This Matters

A skill that references repo-level docs can work during authoring and fail after installation. The authoring repo has `docs/`, but installed skills often contain only the skill directory. If required reference material lives outside the skill package, future agents lose the context that made the skill reliable.

Duplicating an installable skill under a docs snapshot creates the opposite problem: the repository now contains two copies with different layouts and update paths. That makes drift likely and can confuse wildcard installers or future maintainers about which copy is authoritative.

The safe pattern is to preserve one installable package per skill and put runtime reference material next to the skill that consumes it.

## When to Apply

- Importing external documentation to support a local skill
- Turning repo docs or upstream docs into a reusable skill package
- Adding refresh scripts for bundled docs snapshots
- Reviewing a PR that creates `docs/vendor/`, nested `skills/` trees, or duplicate copies of existing vendored skills
- Updating `skills-best-practices` or another skill that relies on long reference material

## Examples

### Bad: skill-required docs only at repo level

```text
docs/reference/agent-skill-authoring-best-practices.md
lefant/skills-best-practices/SKILL.md  # points to repo-level docs/reference
```

This works in the source checkout but breaks once only `lefant/skills-best-practices/` is installed.

### Good: skill-required docs packaged with the skill

```text
lefant/skills-best-practices/references/upstream/agentskills/docs/specification.mdx
lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/best-practices.mdx
lefant/skills-best-practices/references/update-upstream-docs.md
lefant/skills-best-practices/scripts/update-agentskills-docs.sh
```

The deployed skill receives the docs it needs, and the refresh instructions travel with it.

### Bad: duplicate an existing vendored installable skill in docs

```text
docs/vendor/anthropics/skills/skill-creator/...
vendor/anthropics/skill-creator/...
```

This duplicates the same upstream package and uses the nested upstream `skills/` layout that this repo intentionally avoids.

### Good: reference the existing installable package once

```text
vendor/anthropics/skill-creator/
docs/reference/agent-skill-source-map.md  # explains relationship, does not duplicate package
```

The source map names the authoritative package and explains when to consult it.

## Related

- `docs/devlog/2026-04-29_import-agent-skill-reference-docs.md` — implementation log for the import
- `docs/reference/agent-skill-authoring-best-practices.md` — synthesized authoring guidance
- `docs/reference/agent-skill-source-map.md` — source map for imported guidance
- `lefant/skills-best-practices/SKILL.md` — runtime skill entry point
- `lefant/skills-best-practices/references/update-upstream-docs.md` — refresh instructions for the bundled docs snapshot
- `lefant/skills-best-practices/scripts/update-agentskills-docs.sh` — refresh script
- `docs/solutions/workflow-issues/vendor-skill-layout-discoverability-2026-04-29.md` — related layout guidance for vendored installable skills
