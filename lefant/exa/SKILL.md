---
name: exa
description: Use Exa for web search, code context lookup, and company or people research via the official SDK, direct API calls, or MCP. Use when setting up Exa in a coding-agent environment, testing EXA_API_KEY, configuring Exa MCP, or looking up current web information.
metadata: {"openclaw":{"emoji":"🔎","requires":{"env":["EXA_API_KEY"]},"primaryEnv":"EXA_API_KEY","skillKey":"exa","os":["linux","darwin","win32"]}}
---

# Exa

Use this skill for Exa SDK, API, and MCP work.

## Requirement: EXA_API_KEY

Before any Exa call, verify that `EXA_API_KEY` is present without printing it:

```bash
test -n "${EXA_API_KEY:-}"
```

In OpenClaw, this skill declares `primaryEnv: EXA_API_KEY`, so prefer configuring `skills.entries.exa.apiKey` as a SecretRef. OpenClaw injects the key for the agent run.

For manual use outside OpenClaw, export `EXA_API_KEY` from your local secret manager or an untracked local env file. Do not write API keys into tracked repo files or echo them into logs.

## First documentation step

Read `references/llms.txt` first.

That file is a full local snapshot of Exa's documentation index and points to:
- JavaScript SDK docs
- Exa MCP setup
- coding-agent search and contents guides
- vertical-specific references like code, company, news, and people search
- Exa-published agent skill templates

Important pages usually worth following from the index:
- `https://exa.ai/docs/sdks/javascript-sdk.md`
- `https://exa.ai/docs/reference/search-api-guide-for-coding-agents.md`
- `https://exa.ai/docs/reference/contents-api-guide-for-coding-agents.md`
- `https://exa.ai/docs/reference/exa-mcp.md`
- `https://exa.ai/docs/reference/code-search-claude-skill.md`

If the task is to add a brand-new Exa integration to a project, Exa's coding-agent docs recommend using Dashboard Onboarding first:
- `https://dashboard.exa.ai/onboarding`

## Preferred in this repo

For repo-local automation, prefer this order:

1. official JavaScript SDK (`exa-js`) via a small Node helper
2. direct HTTP (`/search`, `/contents`) for low-level debugging and inspection
3. MCP only when the user specifically wants tool-based agent integration

Operational note:
- if handwritten HTTP fails but the key should work, test the official SDK before concluding that the key is invalid
- official SDK behavior can succeed where a naive raw HTTP request fails due to request-shape or compatibility details

## Known-good local helper pattern

This skill ships reusable helper examples at:
- `scripts/exa-search.mjs`
- `scripts/exa-contents.mjs`

Use it as a starting point for repo-local helpers.

Recommended workflow:
- keep reusable Exa helpers in the target repo's `scripts/` directory
- install `exa-js` locally in the workspace; do not assume global npm access
- if local tooling lives under `.tools/`, resolve packages from there
- rely on OpenClaw SecretRef skill injection when running inside OpenClaw
- for manual runs, load `EXA_API_KEY` from an untracked local secret source
- emit compact normalized JSON for downstream agent use

The bundled helper is designed to resolve `exa-js` from the current working directory or `.tools/`, so it works in restricted environments that do not allow global installs.

Known-good invocation patterns once copied into a repo:

```bash
node scripts/exa-search.mjs 'Altego AI founders' 3
node scripts/exa-contents.mjs 'https://altego.ai/about' highlights 2000
```

Recommended JSON shape for helper output:
- search helper:
  - `query`
  - `count`
  - `results[].title`
  - `results[].url`
  - `results[].publishedDate`
  - `results[].highlights`
- contents helper:
  - `url`
  - `mode`
  - `result.title`
  - `result.url`
  - `result.publishedDate`
  - `result.author`
  - `result.highlights`
  - `result.text`

## Decision rule: search vs contents

Use this default rule:
- use `exa.search()` or `/search` when discovering sources
- use `exa.getContents()` or `/contents` once you know the exact URL
- request `highlights` first for token efficiency
- request full `text` only when deeper reading is required

## Minimal SDK usage

```js
import Exa from "exa-js";

const exa = new Exa();

const result = await exa.search("latest developments in AI safety research", {
  type: "auto",
  numResults: 10,
  contents: {
    highlights: {
      maxCharacters: 4000,
    },
  },
});
```

Minimal contents retrieval:

```js
import Exa from "exa-js";

const exa = new Exa();

const { results } = await exa.getContents(["https://altego.ai/about"], {
  text: true,
});
```

## Minimal curl usage

Basic search request:

```bash
curl -fsS 'https://api.exa.ai/search' \
  -H "x-api-key: $EXA_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "latest developments in AI safety research",
    "type": "auto",
    "numResults": 10,
    "contents": {
      "highlights": {
        "maxCharacters": 4000
      }
    }
  }'
```

Use `type: "auto"` by default unless the user explicitly needs a different search mode.

## Known-good smoke test

To verify the key works against a real company lookup, use this two-step flow.

### 1. Search for the target

SDK/helper path:

```bash
node scripts/exa-search.mjs 'co-founders of altego.ai' 3
```

Raw HTTP path:

```bash
curl -fsS 'https://api.exa.ai/search' \
  -H "x-api-key: $EXA_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "co-founders of altego.ai",
    "type": "auto",
    "numResults": 5,
    "contents": {
      "highlights": {
        "maxCharacters": 1200
      }
    }
  }'
```

This query works as a smoke test, but search results may include noisy `AlterEgo` matches.

### 2. Fetch the authoritative page contents

SDK/helper path:

```bash
node scripts/exa-contents.mjs 'https://altego.ai/about' text 5000
```

SDK path:

```js
import Exa from "exa-js";

const exa = new Exa();

const { results } = await exa.getContents(["https://altego.ai/about"], {
  text: { maxCharacters: 5000 },
});
```

Raw HTTP path:

```bash
curl -fsS 'https://api.exa.ai/contents' \
  -H "x-api-key: $EXA_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "urls": ["https://altego.ai/about"],
    "text": {
      "maxCharacters": 5000
    }
  }'
```

At the time this skill was created, that page identified the founders as:
- Mats Horn
- Fabian Linzberger

Use `/contents` when you already know the URL and want the cleanest answer from a known page.

## MCP

Treat MCP as optional, not primary.

Base MCP URL:

```text
https://mcp.exa.ai/mcp
```

If the client supports key-in-URL remote config:

```text
https://mcp.exa.ai/mcp?exaApiKey=YOUR_API_KEY
```

Optional tool restriction example:

```text
https://mcp.exa.ai/mcp?exaApiKey=YOUR_API_KEY&tools=web_search_exa,get_code_context_exa,people_search_exa
```

Codex example:

```bash
codex mcp add exa --url https://mcp.exa.ai/mcp
```

If tools do not appear after config changes, restart the MCP client.

## API usage guidance

Prefer these defaults unless the task needs something else:
- `type: "auto"`
- compact `highlights` for search-result evidence
- `/contents` or `exa.getContents()` for known URLs
- domain filters only when the user needs tighter source control

Typical categories:
- `company`
- `people`
- `news`
- `research paper`
- `personal site`
- `financial report`

## Common mistakes to avoid

Avoid outdated or incorrect parameter shapes.

Common mistakes called out in Exa docs include:
- using deprecated `useAutoprompt`
- using `includeUrls` or `excludeUrls` instead of domain filters
- putting `text` or `highlights` at the top level of `/search` instead of under `contents`
- confusing `/search` payload shape with `/contents` payload shape

When unsure, read the relevant page from `references/llms.txt` and follow the current docs.
