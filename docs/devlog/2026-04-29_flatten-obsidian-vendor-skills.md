# 2026-04-29 — Flatten Obsidian vendor skills

Flattened the vendored Kepano Obsidian skills so wildcard skill installs can discover them directly under `vendor/kepano/<skill>/` instead of the upstream `vendor/kepano/obsidian-skills/skills/<skill>/` nesting.

## What changed

- moved Obsidian skills to flattened vendor paths:
  - `vendor/kepano/defuddle/`
  - `vendor/kepano/json-canvas/`
  - `vendor/kepano/obsidian-bases/`
  - `vendor/kepano/obsidian-cli/`
  - `vendor/kepano/obsidian-markdown/`
- kept the upstream license at `vendor/kepano/LICENSE`
- added `fetch_skillset` and `fetch_file` helpers to `scripts/update-vendor.sh`
- updated the Kepano refresh path to extract upstream `skills/*` into flattened local directories
- documented the flattened vendor layout in `vendor/README.md`
- added root README quality checks to catch nested `vendor/**/skills` directories and plugin-native bundles that need non-skill assets
- removed the tentative `EveryInc/compound-engineering-plugin` vendoring path because that plugin needs agent and plugin-layer handling outside this skills-only repository

## Validation

- `bash -n scripts/update-vendor.sh`
- `find vendor -type d -name skills -print` returns no nested skill containers
- vendored `SKILL.md` frontmatter sanity check passes
- no remaining `EveryInc` or `compound-engineering` references in repository docs or update script

## Notes

The repository now treats `scripts/update-vendor.sh` as the source-to-local mapping registry for larger upstream repositories. Symlinks are avoided because package copying, Docker, Windows, and wildcard skill installers may not preserve or traverse them consistently.
