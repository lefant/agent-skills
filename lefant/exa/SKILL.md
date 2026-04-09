---
name: exa
description: Use Exa for web search, code context lookup, and company or people research via API or MCP. Use when setting up Exa in a coding-agent environment, testing Exa search requests, configuring Exa MCP, verifying that EXA_API_KEY works, or looking up current web information with Exa.
---

# Exa

Use this skill for Exa API and MCP work.

## Requirement: EXA_API_KEY

Before any Exa API call, verify that `EXA_API_KEY` is present:

```bash
echo "$EXA_API_KEY"
```

If it is empty, stop and ask the user to export it first.

Example:

```bash
export EXA_API_KEY="your_key_here"
```

If the user stores secrets in a local env file, source that file first and then continue.

Do not write API keys into tracked repo files.

## First documentation step

Read `references/llms.txt` first.

That file is a full local snapshot of Exa's online documentation index and points to:
- Exa MCP setup
- coding-agent search and contents guides
- vertical-specific references like code, company, news, and people search
- Claude-oriented Exa skill templates

Important pages usually worth following from the index:
- `https://exa.ai/docs/reference/exa-mcp.md`
- `https://exa.ai/docs/reference/search-api-guide-for-coding-agents.md`
- `https://exa.ai/docs/reference/contents-api-guide-for-coding-agents.md`
- `https://exa.ai/docs/reference/code-search-claude-skill.md`

If the task is to add a brand-new Exa integration to a project, Exa's coding-agent docs recommend using Dashboard Onboarding first:
- `https://dashboard.exa.ai/onboarding`

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

Use `type: "auto"` by default unless the user explicitly needs faster or deeper search behavior.

## Known-good smoke test

To verify the key works against a real company lookup, use this two-step flow.

### 1. Search for the target

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

This query works as an API smoke test, but search results may include noisy `AlterEgo` matches.

### 2. Fetch the authoritative page contents

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
- compact `highlights` for search result evidence
- `/contents` for known URLs
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
