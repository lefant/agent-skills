---
date: 2026-04-09
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-04-09

**Implementation**: Added a custom `exa` skill with local API-key requirements, a working curl search pattern, and a vendored Exa documentation index snapshot

## Summary

Added a new custom `lefant/exa` skill to the `agent-skills` repo so local agents can use Exa consistently without hard-coding credentials into repo files. The skill requires `EXA_API_KEY` from the environment, points agents at a vendored snapshot of Exa's published `llms.txt` documentation index, and includes a minimal curl request that matches the current Exa API shape. It also records a known-good smoke test flow using `altego.ai` founder lookup, then verifies the authoritative answer through `/contents` on `https://altego.ai/about`. Updated the repo README so the new custom skill appears in the documented skill list.

## Plan vs Reality

**What was planned:**
- [ ] Add a local custom Exa skill under `lefant/`
- [ ] Include the full Exa `llms.txt` index in the skill resources
- [ ] Keep secret handling environment-based rather than tracked in git
- [ ] Validate the skill with a real Exa API call
- [ ] Document the session in a repo devlog

**What was actually implemented:**
- [x] Added `lefant/exa/SKILL.md`
- [x] Added `lefant/exa/references/llms.txt` from `https://exa.ai/docs/llms.txt`
- [x] Required `EXA_API_KEY` in the skill and explicitly prohibited writing API keys into tracked files
- [x] Added working curl examples for `/search` and `/contents`
- [x] Included the proven `altego.ai` founder lookup flow as a smoke-test pattern
- [x] Re-ran the founder lookup through Exa using the local environment key and confirmed `/contents` returned founders Mats Horn and Fabian Linzberger from `https://altego.ai/about`
- [x] Updated `README.md` to list the new custom skill
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- The broader web search query for `altego.ai` founders was noisy because Exa also surfaced similarly named `AlterEgo` entities.
- The user-provided setup guide mixed older parameter spellings with current Exa docs.

**Solutions found:**
- Treated the broad search query as the initial smoke test, then used `/contents` on the known authoritative URL `https://altego.ai/about` to confirm the founders deterministically.
- Followed Exa's current published docs and working API behavior for the shared skill, using current request shapes like `numResults` and `maxCharacters`.

## Learnings

- Exa's `llms.txt` is a useful agent-oriented entrypoint because it exposes both documentation pages and Exa-published Claude skill templates.
- `/contents` is the more reliable path once the authoritative URL is known, especially when a search query is vulnerable to brand-name collisions.
- For a shared public skill, requiring `EXA_API_KEY` from the environment is much safer than documenting any repo-local secret file path.

## Next Steps

- [ ] Update downstream repos that pin `github:lefant/agent-skills` so they pull in the new `exa` skill
- [ ] Consider refreshing the vendored `references/llms.txt` snapshot when Exa's doc index changes materially
