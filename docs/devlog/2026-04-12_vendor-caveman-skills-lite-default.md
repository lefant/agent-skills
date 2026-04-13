---
date: 2026-04-12
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-04-12

**Implementation**: Vendored JuliusBrussee/caveman skills into the shared bundle and set the default Caveman intensity to `lite`

## Summary

Added the upstream Caveman skill set from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) into `vendor/JuliusBrussee/` so the shared `lefant/agent-skills` bundle exposes Caveman across supported coding agents. Included the main `caveman` skill plus `caveman-help`, `caveman-commit`, `caveman-review`, and `caveman-compress`. Applied a small local compatibility patch so the shared bundle defaults the main Caveman skill to `lite` instead of upstream `full`, and made the `caveman-compress` execution instructions portable for our vendored skill layout.

This follows the same pattern `toolnix` already uses: once a downstream consumer bumps its pinned `agent-skills` input, the managed skill tree will include the new Caveman directories automatically without extra module wiring.

## Plan vs Reality

**What was planned:**
- [ ] Vendor the Caveman skill into the shared `agent-skills` repository
- [ ] Keep the update path reproducible through `scripts/update-vendor.sh`
- [ ] Make the shared bundle prefer Caveman `lite` as the default mode
- [ ] Document the new vendor source and any review caveats
- [ ] Record the change in a repo devlog

**What was actually implemented:**
- [x] Added `vendor/JuliusBrussee/caveman/`
- [x] Added `vendor/JuliusBrussee/caveman-help/`
- [x] Added `vendor/JuliusBrussee/caveman-commit/`
- [x] Added `vendor/JuliusBrussee/caveman-review/`
- [x] Added `vendor/JuliusBrussee/caveman-compress/` including upstream scripts and `SECURITY.md`
- [x] Updated `scripts/update-vendor.sh` with Caveman fetch entries
- [x] Added post-fetch patches for the lefant-specific `lite` default and portable `caveman-compress` path usage
- [x] Updated `vendor/README.md` with the new source row and a security-review note for `caveman-compress`
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- Upstream Caveman defaults to `full`, but the requested local behavior was `lite`.
- `caveman-compress` documents execution from the upstream repo layout (`cd caveman-compress`), which is awkward once the skill is vendored into a shared skill tree.

**Solutions found:**
- Kept the vendored source as close to upstream as possible, then encoded the `lite` default as a small deterministic post-fetch patch in `scripts/update-vendor.sh`.
- Patched `caveman-compress/SKILL.md` to use `{baseDir}` and the adjacent `scripts/` directory so the instructions remain valid after vendoring.

## Learnings

- Caveman is better represented here as a small family of related skills, not just the primary speaking-style skill, because `caveman-commit`, `caveman-review`, and `caveman-help` are independently useful in the shared bundle.
- The current `toolnix` managed-skill-tree design already handles new bundle content cleanly; no `toolnix` code changes are needed beyond bumping the pinned `agent-skills` input.
- Vendored skills that include helper scripts often need a small portability patch so their path instructions still make sense when symlinked into agent-specific skill directories.

## Next Steps

- [ ] Bump the pinned `agent-skills` input in downstream repos such as `~/git/lefant/toolnix` so consumers receive the new Caveman skills
- [ ] Consider whether any agent-specific always-on Caveman activation should live downstream in agent configs rather than in this shared skill repository
