---
title: Vendor Skill Layout Must Stay Flat for Discovery
date: 2026-04-29
category: workflow-issues
module: vendor skill maintenance
problem_type: workflow_issue
component: tooling
severity: high
applies_when:
  - "Vendoring skills from upstream repositories with nested skills/ directories"
  - "Adding or refreshing vendor entries through scripts/update-vendor.sh"
  - "Debugging skills that appear present in git but are missing after wildcard install"
symptoms:
  - "Vendored SKILL.md files exist under vendor/<source>/<repo>/skills/<skill>/ but are not installed"
  - "Wildcard skill installs silently miss nested upstream skill directories"
root_cause: missing_tooling
resolution_type: tooling_addition
tags: [vendor, skills, discoverability, update-vendor, obsidian]
---

# Vendor Skill Layout Must Stay Flat for Discovery

## Context

The Kepano Obsidian skills were vendored under the upstream repository shape:

```text
vendor/kepano/obsidian-skills/skills/<skill>/SKILL.md
```

That layout preserved the upstream tree, but it did not match this repository's install model. Wildcard skill installation expects skill roots to be directly discoverable under the bundled skill tree. The nested `skills/` container meant the Obsidian skills could exist in git while still being silently absent from deployment.

Session history did not surface prior related attempts; the issue was identified and resolved in the current session.

## Guidance

Flatten vendored skill directories into the local shape:

```text
vendor/<source>/<skill>/SKILL.md
```

For upstream repositories that store skills below a shared `skills/` directory, keep the upstream-to-local mapping in `scripts/update-vendor.sh` instead of preserving the upstream container. The Kepano mapping now uses `fetch_skillset`:

```bash
fetch_skillset "kepano/obsidian-skills" "skills" "$VENDOR_DIR/kepano" \
    defuddle \
    json-canvas \
    obsidian-bases \
    obsidian-cli \
    obsidian-markdown || true
fetch_file "kepano/obsidian-skills" "LICENSE" "$VENDOR_DIR/kepano/LICENSE" || true
```

This produces discoverable local skill roots:

```text
vendor/kepano/defuddle/SKILL.md
vendor/kepano/json-canvas/SKILL.md
vendor/kepano/obsidian-bases/SKILL.md
vendor/kepano/obsidian-cli/SKILL.md
vendor/kepano/obsidian-markdown/SKILL.md
```

Add an automated layout check whenever changing vendored skills:

```bash
./scripts/check-vendor-layout.sh
```

The check fails if:

- any `vendor/**/skills` directory exists
- any `vendor/**/skills/*/SKILL.md` exists
- a vendored skill is not shaped as `vendor/<source>/<skill>/SKILL.md`
- frontmatter `name:` does not match the skill directory
- frontmatter `description:` is missing
- duplicate vendor skill names exist

## Why This Matters

A nested vendor tree can look correct during review because the files are present and the upstream structure is intact. The failure only appears later when an installer scans for skills and misses nested roots. That makes the bug easy to ship and hard to notice: the skill content is in the repository, but users never receive it.

Flattening trades upstream directory fidelity for deployment correctness. `scripts/update-vendor.sh` becomes the source-path registry, while the checked-in vendor tree remains shaped for this repository's consumers.

Symlinks are not a good substitute. Package copying, Docker contexts, Windows environments, and wildcard skill installers may not preserve or traverse symlinked skill directories consistently.

## When to Apply

- When vendoring from a repository that contains `skills/<skill>/`
- When a source repository is a plugin or package with more than skill directories
- When adding a new vendor update helper or source mapping
- When a skill appears in git but does not appear in the installed skill list
- Before committing any broad vendor refresh

## Examples

### Bad: preserve upstream nesting

```text
vendor/kepano/obsidian-skills/skills/obsidian-cli/SKILL.md
```

The skill is present in the repository, but an installer scanning `vendor/*/*/SKILL.md` will not see it.

### Good: flatten for local discovery

```text
vendor/kepano/obsidian-cli/SKILL.md
```

The upstream source is still documented in `vendor/README.md`, and the source mapping is reproducible through `scripts/update-vendor.sh`.

### Good: handle plugin-native bundles elsewhere

Do not force plugin-native bundles into the skills-only vendor tree when they require agents, commands, MCP configuration, or other non-skill assets. Handle those in a plugin/package layer that can install the whole bundle correctly.

## Related

- `README.md` — Vendor Quality Checks section
- `vendor/README.md` — flattened vendor layout and source table
- `scripts/update-vendor.sh` — source-to-local mapping registry
- `scripts/check-vendor-layout.sh` — automated layout guard
- `docs/devlog/2026-04-29_flatten-obsidian-vendor-skills.md` — implementation log for flattening Kepano Obsidian skills
- `docs/devlog/2026-04-29_vendor-layout-qa-check.md` — implementation log for adding the QA check
