# 2026-04-29 — Vendor layout QA check

Added a concrete QA script to prevent vendored skills from being hidden inside nested upstream `skills/` directories.

## What changed

- added `scripts/check-vendor-layout.sh`
- updated `README.md` to run the script during vendor review
- the script fails when:
  - any `vendor/**/skills` directory exists
  - any `vendor/**/skills/*/SKILL.md` exists
  - a vendored skill is not shaped as `vendor/<source>/<skill>/SKILL.md`
  - frontmatter `name:` does not match the skill directory
  - frontmatter `description:` is missing
  - duplicate vendor skill names exist

## Why

The previous Kepano Obsidian layout nested skills under `vendor/kepano/obsidian-skills/skills/<skill>/`. Wildcard skill installers likely did not discover those skills, causing Obsidian skills to be silently undeployed. The check makes this failure mode explicit and blocks recurrence.

## Validation

- `./scripts/check-vendor-layout.sh`
- output: `Vendor layout OK (33 skills).`
