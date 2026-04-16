# 2026-04-29 — Import agent skill reference docs

Imported the agent-skill authoring reference docs from the `8172827` cherry-pick and adapted them to this repository's existing skill layout.

## What changed

- added `docs/reference/agent-skill-authoring-best-practices.md`
- added `docs/reference/agent-skill-source-map.md`
- added the curated public Agent Skills docs snapshot under `lefant/skills-best-practices/references/upstream/agentskills/`
- added `lefant/skills-best-practices/references/update-upstream-docs.md` for refreshing the docs snapshot
- added `lefant/skills-best-practices/scripts/update-agentskills-docs.sh` so the skill can refresh its bundled upstream docs from inside the skill package

## Double-check against existing skills

- moved the Agent Skills upstream docs into `lefant/skills-best-practices/` so deployed skill targets receive the reference material without repo-level `docs/`
- kept `vendor/anthropics/skill-creator/` as the installable upstream Anthropic skill package
- removed the duplicate imported `docs/vendor/anthropics/skills/skill-creator/` snapshot because it duplicated `vendor/anthropics/skill-creator/` and used the nested upstream `skills/` layout this repo avoids
- updated the source map and best-practices doc to point at actual repo skill roots: `lefant/<skill>/` and `vendor/<source>/<skill>/`

## Validation

- `./scripts/check-vendor-layout.sh`
- confirmed `docs/vendor/` is absent so skill-required docs now live inside the skill package
- searched imported docs for stale references to the source repo's skill paths and source-specific domain material
- scanned `lefant/` and `vendor/` skill names; only the pre-existing `tasknotes` duplicate remains, and this import does not change it
