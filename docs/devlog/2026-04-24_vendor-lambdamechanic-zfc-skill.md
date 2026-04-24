# 2026-04-24 — Vendor lambdamechanic zfc skill

Added the upstream `zfc` skill from [`lambdamechanic/skills`](https://github.com/lambdamechanic/skills) into the vendored skill bundle at `vendor/lambdamechanic/zfc/`.

## What changed

- added `vendor/lambdamechanic/zfc/SKILL.md`
- added the upstream source to `vendor/README.md`
- updated `scripts/update-vendor.sh` so future vendor refreshes fetch `zfc`
- appended a reference link to Steve Yegge's Zero Framework Cognition article in the vendored skill and vendor docs

## Notes

The vendored skill is currently a single `SKILL.md` file upstream, so no extra helper files or scripts were required.
