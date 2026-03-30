---
date: 2026-03-30
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-03-30

**Implementation**: Disabled vendored obra superpowers skills and removed local copies

## Summary

Disabled fetching of the `obra/superpowers` skills in the vendor update script, moved their source entry into a dedicated "Disabled for now" section in `vendor/README.md`, and removed the existing `vendor/obra/` directory so setup automation no longer picks those skills up.

## Plan vs Reality

**What was planned:**
- [ ] Disable `obra/superpowers` for now
- [ ] Keep setup automation from discovering the vendored skills
- [ ] Record the change in a short devlog

**What was actually implemented:**
- [x] Commented out the `obra/superpowers` fetches in `scripts/update-vendor.sh`
- [x] Added a `Disabled for now` section to `vendor/README.md`
- [x] Removed `vendor/obra/brainstorming` and `vendor/obra/using-superpowers`
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- Setup automation would still discover disabled skills if the vendored directories remained present.

**Solutions found:**
- Removed `vendor/obra/` entirely in addition to disabling updates and documenting the temporary state.

## Learnings

- Disabling a vendored source in docs and update automation is not enough when downstream tooling scans directories directly.

## Next Steps

- [ ] Re-enable `obra/superpowers` in the update script and sources table if these skills should be restored later
