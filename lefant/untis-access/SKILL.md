---
name: untis-access
description: Access WebUntis accounts and APIs for debugging, research, or automation. Use when the user wants to log into a WebUntis tenant, read inbox messages, fetch guardian/dependent timetables, inspect homework or exams, compare WebUntis library implementations, or validate auth flows such as JSON-RPC login, JWT minting, or shared-secret OTP.
---

# Untis Access

Use this skill for direct WebUntis access work, especially when repo wrappers are incomplete and the fastest path is to prove the live API behavior.

## Scope

Use this skill for:
- reading WebUntis inbox messages or message details
- reading guardian/dependent timetable data
- investigating homework or exam availability
- comparing local WebUntis-related repos and auth models
- building or running proof scripts against a live tenant

Do not use this skill for:
- generic browser automation if direct HTTP access already works
- non-WebUntis school systems
- UI polish or frontend work unrelated to WebUntis data access

## Default workflow

1. Read `references/research/2026-04-16_webuntis-message-access.md` for the proven tenant flow and repo overview.
2. Read `references/auth-and-env.md` and confirm the credential file convention.
3. Start from the bundled script closest to the task:
   - `scripts/read-latest-message.py` for inbox access
   - `scripts/read-timetable.py` for guardian/dependent timetable access
4. Only branch into repo comparison or alternate auth when the default scripts do not cover the target surface.
5. Validate by running the script and confirming the response is real JSON data, not the SPA shell.

## Defaults

- default credential source: `~/.env.webuntis`
- default tenant config: provide `WEBUNTIS_HOST` and `WEBUNTIS_SCHOOL` locally; do not commit tenant-specific values into the skill
- default auth path: JSON-RPC `authenticate` → `/WebUntis/api/token/new` → `/WebUntis/api/...`
- default implementation strategy: direct HTTP proof first, repo patch second
- fallback auth path: shared-secret TOTP only when you intentionally need the `jsonrpc_intern.do` flow

## Gotchas

- On this tenant, the working authenticated base is `/WebUntis/api/...`, not bare `/api/...`.
- Guardian accounts do not work with old timetable JSON-RPC element type assumptions; resolve dependents via `timetable/menu` first.
- JWT lifetime is short. Mint a fresh token every run.
- `JSESSIONID` server-side lifetime is unclear. For unattended jobs, fresh login per run is safer than session reuse.
- `SchoolUtils/WebUntis` only covers inbox preview data; full message detail needs direct REST calls or repo patching.
- `kaiser-jan/scriptable-untis` is a good timetable reference, but it is not obviously guardian-aware out of the box.

## Validation

Before finishing:
- run the relevant bundled script
- verify the response contains expected data for the target surface
- verify the response is JSON and not HTML
- if a route fails, compare it against the proven endpoints in `references/research/2026-04-16_webuntis-message-access.md`

## Read next

- `references/auth-and-env.md` when setting up credentials or documenting auth assumptions; do not commit real usernames, tenant values, or personal timetable data into the skill
- `references/research/2026-04-16_webuntis-message-access.md` when comparing repos, auth models, or endpoint choices
- `references/proofs/2026-04-16_webuntis-message-access_README.md` when you need the exact proved message and timetable flows

## Available scripts

- `scripts/read-latest-message.py` — log in, mint JWT, list inbox, fetch newest full message
- `scripts/read-timetable.py` — log in, resolve dependent student, print weekly timetable, optionally print teacher code mappings
