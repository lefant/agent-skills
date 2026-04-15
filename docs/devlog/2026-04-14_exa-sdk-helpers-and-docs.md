---
date: 2026-04-14
status: ✅ COMPLETED
related_research: docs/research/2026-04-14_exa-skill-improvements-vs-nodejs-helper.md
related_issues: []
---

# Implementation Log - 2026-04-14

**Implementation**: Updated the `lefant/exa` skill to prefer the official SDK, added reusable `search` and `getContents` Node helpers, and verified both against the live Exa API

## Summary

Expanded the custom `lefant/exa` skill so it reflects the repo-local SDK workflow that proved more reliable than handwritten HTTP in practice. Added two reusable helper scripts under `lefant/exa/scripts/`: one for `search` and one for `getContents`. Both helpers load `EXA_API_KEY`, resolve `exa-js` from the current workspace or `.tools/`, and emit normalized JSON for downstream agent use. I also moved the earlier review note into `docs/research/`, updated the skill documentation and repo README, installed Node on the VM to run a real smoke test, and fixed one helper bug discovered during testing (`Exa is not a constructor` caused by the package export shape).

## Plan vs Reality

**What was planned:**
- [ ] Move the Exa improvement note into `docs/research/`
- [ ] Update `lefant/exa` to prefer the SDK-first workflow
- [ ] Add a working local helper example for search
- [ ] Test the helper with a real Exa query
- [ ] Add a devlog entry

**What was actually implemented:**
- [x] Moved the review note into `docs/research/2026-04-14_exa-skill-improvements-vs-nodejs-helper.md`
- [x] Updated `lefant/exa/SKILL.md` to favor `exa-js`, clarify `search` vs `contents`, and demote MCP to optional
- [x] Added `lefant/exa/scripts/exa-search.mjs`
- [x] Added `lefant/exa/scripts/exa-contents.mjs`
- [x] Updated `README.md` to reflect SDK/API/MCP support in the Exa skill description
- [x] Installed Node and npm on the VM to enable runtime verification
- [x] Verified `exa-search.mjs` with a live `co-founders of altego.ai` query
- [x] Verified `exa-contents.mjs` with `https://altego.ai/about`
- [x] Fixed the helper import/constructor bug discovered during runtime testing
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- The first working version of `exa-search.mjs` failed at runtime with `Exa is not a constructor` because `exa-js` exports both named and nested default shapes depending on how the resolved module is loaded.
- Search results for `altego.ai` remain noisy because Exa also returns `AlterEgo` matches from unrelated sources.
- The VM initially did not have Node installed, so runtime verification was blocked.

**Solutions found:**
- Changed helper module loading to prefer `module.Exa`, then `module.default?.Exa`, before falling back further.
- Kept the noisy founder query as a smoke test, but used `getContents` on `https://altego.ai/about` for authoritative verification.
- Installed `nodejs` and `npm` via `apt` on the VM before re-running the helpers in a temporary workspace with `exa-js` installed.

## Learnings

- A skill-local helper example is the right compromise for this repo: reusable guidance without forcing the repo itself to become a Node project.
- With `exa-js`, import shape matters when resolving packages dynamically instead of through a normal static `import Exa from "exa-js"` path.
- The combination of `search` for discovery and `getContents` for authoritative extraction is the right default workflow to encode in the skill.

## Next Steps

- [ ] Bump downstream repos that pin `github:lefant/agent-skills` so the new Exa helpers become available in managed skill trees
- [ ] Consider extracting shared helper utilities if more Exa scripts are added later
