---
date: 2026-04-16
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-04-16

**Implementation**: Added the new custom `untis-access` skill, bundled sanitized WebUntis research and proof scripts, and validated the skill in a fresh pi eval run

## Summary

Added `lefant/untis-access/` as a new in-house skill for direct WebUntis access work. Moved the proven message and timetable scripts plus supporting research into the skill package, sanitized bundled docs to remove tenant-specific personal data, documented the local credential convention, and added a small sanitized eval note. Then ran pi in a fresh temporary workdir with only the copied skill, local credential file, and local setup README to confirm the skill could still retrieve messages, retrieve guardian timetable data, compare local repos, and describe its credential format.

## Plan vs Reality

**What was planned:**
- [ ] Create a reusable `untis-access` skill from the WebUntis research/proof work
- [ ] Move the proofs and research into the skill package
- [ ] Keep personal account and timetable data out of the repo
- [ ] Validate the skill in a fresh eval setup
- [ ] Write a devlog entry

**What was actually implemented:**
- [x] Created `lefant/untis-access/` with `SKILL.md`, references, assets, and scripts
- [x] Bundled sanitized copies of the research and proof documentation under `references/`
- [x] Bundled `read-latest-message.py` and `read-timetable.py` under `scripts/`
- [x] Documented the local credential convention in `references/auth-and-env.md`
- [x] Added a config-completeness hint so agents check for `WEBUNTIS_HOST` and `WEBUNTIS_SCHOOL` before running scripts
- [x] Added a sanitized eval artifact under `lefant/untis-access/assets/`
- [x] Updated `README.md` to list the new skill
- [x] Ran a fresh temporary eval pass and confirmed message/timetable/credential prompts worked cleanly
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- The original research and proof material contained live tenant, student, teacher, and message details that should not live in the shared skill repo.
- The first fresh eval run exposed friction because the scripts now required `WEBUNTIS_HOST` and `WEBUNTIS_SCHOOL`, while the local credential file initially only had username and password.
- One eval prompt about repo comparison was correct overall but still slightly sloppy about one local repo path.

**Solutions found:**
- Rewrote bundled docs to use placeholders and redacted examples while keeping the useful API and repo-comparison conclusions.
- Added the missing local config values to `~/.env.webuntis` and documented a completeness check in the skill.
- Preserved a sanitized eval summary that records the meaningful lessons without leaking personal data.

## Learnings

- This skill is a good example of why self-contained packaging matters: the runnable scripts, auth notes, proof README, and research all need to travel together.
- Direct HTTP proofs remain the most reliable implementation basis for this WebUntis use case.
- Guardian timetable access should explicitly resolve dependent students before fetching timetable entries.
- Even when a skill succeeds in eval, the quality of the local setup instructions strongly affects how much agent recovery work is needed.

## Next Steps

- [ ] Tighten the repo-comparison guidance further if path accuracy during eval becomes important
- [ ] Add homework and exam proof scripts if those surfaces become part of the intended skill scope
