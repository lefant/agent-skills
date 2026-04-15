---
date: 2026-04-14
researcher: OpenAI Codex
repository: lefant/agent-skills
topic: "Exa skill improvements vs a repo-local Node.js helper"
tags: [research, exa, sdk, skills]
status: complete
last_updated: 2026-04-14
last_updated_by: OpenAI Codex
---

# Research: Exa skill improvements vs a repo-local Node.js helper

## Research Question
How should `lefant/exa` change based on the observed success of a small Node.js helper using the official `exa-js` SDK?

## Summary
The recommendations are good and worth adopting, with one repo-specific adjustment: in this repository, the helper should live inside the skill as a reusable example (`lefant/exa/scripts/exa-search.mjs`) rather than as a top-level repo script.

The main conclusion stands:
- prefer the official `exa-js` SDK for repo-local automation
- keep raw HTTP examples for debugging and `/contents` inspection
- treat MCP as optional rather than primary
- provide a stable JSON-emitting helper pattern for downstream repos

## Review Outcome
The original notes correctly identified practical gaps in the current skill:

1. the skill over-emphasized raw HTTP compared with the official SDK
2. it lacked a reusable repo-local helper workflow
3. it did not mention workspace-local package installs such as `.tools/`
4. it did not specify normalized agent-facing JSON output
5. it could state the `/search` vs `/contents` decision rule more clearly
6. it lacked a known-good helper invocation pattern
7. it positioned MCP too prominently for this repo's needs
8. it did not capture the operational lesson that the SDK may work when handwritten HTTP does not

## Repo-Specific Adjustment
This repo is a skill pack, not an application repo with a managed Node dependency graph. Because of that, the helper should not assume:
- a root `package.json`
- a global npm install
- a fixed `node_modules` location relative to the skill file

The best fit here is a helper example shipped inside the skill that:
- resolves `exa-js` from the current working directory
- also checks workspace-local tooling under `.tools/`
- loads `EXA_API_KEY` from the workspace `.env` when present
- prints normalized JSON for downstream agent use

## Recommended Skill Changes
`lefant/exa` should include:

1. a new “Preferred in this repo” section favoring `exa-js`
2. a “Known-good local helper pattern” section pointing to `scripts/exa-search.mjs`
3. workspace-local install guidance for `.tools/`
4. normalized JSON output guidance with fields such as:
   - `query`
   - `count`
   - `results[].title`
   - `results[].url`
   - `results[].publishedDate`
   - `results[].highlights`
5. a stronger decision rule for `search` vs `contents`
6. MCP repositioned as optional
7. an explicit note to test the official SDK before concluding that an API key is invalid

## Recommended Helper Shape
A good helper pattern for downstream repos is:

```bash
node scripts/exa-search.mjs 'Altego AI founders' 3
```

Expected characteristics:
- uses `import Exa from "exa-js"`
- `new Exa()` reads `EXA_API_KEY` from the environment
- defaults to `type: "auto"`
- requests compact `highlights` first
- emits compact normalized JSON instead of prose

## Decision Rule: Search vs Contents
Use this default rule:
- use `exa.search()` or `/search` when discovering sources
- use `exa.getContents()` or `/contents` once the exact URL is known
- request `highlights` first for token efficiency
- request full `text` only when deeper reading is required

## Conclusion
Yes — a Node.js helper using the official SDK is helpful enough to encode directly into `lefant/exa`.

In this repo, the right implementation is not “top-level helper script with a hard dependency,” but “skill-local helper example plus updated skill guidance.” That keeps the skill reusable while still capturing the operational lessons from the successful SDK path.
