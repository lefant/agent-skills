---
name: proofs
description: Build working mini-app proofs before implementing features. Use when starting non-trivial features, exploring unfamiliar APIs, validating architectural approaches, or when uncertainty exists that code can resolve faster than planning. Triggers on "proof this", "build a proof", "spike it out", "prototype first", or when facing implementation unknowns.
---

# Proofs Skill

Use this skill when building small, working proofs to validate approaches before full implementation. Proofs are documentation with runnable experiments attached.

## Purpose

Proofs answer "can this work?" with code instead of speculation. When facing uncertainty, working code resolves questions faster than written plans.

## When to Create a Proof

Create a proof when:
- Integrating an unfamiliar API or library
- Uncertain if an approach is feasible
- Multiple implementation options exist
- Debugging by isolation helps

Skip proofs when:
- The implementation path is obvious
- You've done this exact thing before
- The task is purely mechanical

## Directory Layout

Proofs are stored in `./docs/proofs/` at the project root. Create this directory on demand when writing the first proof. Each proof is a directory containing a README and associated scripts.

```
docs/proofs/
  2026-02-09_3rd-party-api/
    2026-02-09_3rd-party-api_README.md
    auth-proof.ts
    list-files.ts
    filter-files.ts
    end-to-end.ts
```

## File Naming Convention

`YYYY-MM-DD_short-description/`

The directory and README share the same prefix:
- Directory: `2026-02-09_supabase-auth/`
- README: `2026-02-09_supabase-auth_README.md`

Scripts use descriptive names relevant to what they prove.

## Template

See `template.md` in this skill directory for the proof README format.

## Proof Structure

Each proof directory contains:
- `README.md` - Question, status, run command, result
- Runnable code - Self-contained, minimal dependencies

## Status Values

- **proving**: Work in progress
- **proved**: Concept validated, works as expected
- **failed**: Approach doesn't work (document why)
- **incorporated**: Code merged into main codebase

## Writing Guidelines

1. **Isolate one thing**: Each proof tests ONE hypothesis
2. **Make it runnable**: `cd proofs/001-xxx && npx ts-node main.ts`
3. **Hardcode everything**: Speed over elegance - inline test data, use sandbox keys
4. **Keep it small**: Target < 100 lines of code
5. **Show pass/fail**: Output should clearly indicate success or failure

## Failed Proofs Are Valuable

A failed proof documents learning. Keep failed proofs with notes on why the approach didn't work. This prevents revisiting dead ends.

## Proofs Index

Maintain `docs/proofs/README.md` as an index:

```markdown
# Proofs

| Date | Name | Status | Question |
|------|------|--------|----------|
| 2026-02-09 | 3rd-party-api | proved | Can we access the API? |
| 2026-02-08 | websocket | proving | Does reconnection work? |
| 2026-02-07 | rate-limit | failed | Can we use token bucket? |
```

## Cross-Referencing

Reference proofs from other documentation:
```
See: docs/proofs/2026-02-09_supabase-auth/2026-02-09_supabase-auth_README.md
```

A proof might lead to an ADR documenting why approach X was chosen over Y.

## Browsing Proofs

```bash
# List all proofs
ls -1 docs/proofs/

# Find proofs by status
grep -l "^## Status" docs/proofs/*/*_README.md

# See all proof statuses
grep "proving\|proved\|failed" docs/proofs/*/*_README.md
```

## Creating a Proof

Use the `/proof` command:
```
/proof "Supabase auth with magic links"
```

## Skill Activation

This skill activates when:
- Facing implementation uncertainty
- Exploring unfamiliar APIs or libraries
- User asks "will this work?" or "can we do X?"
- Starting work that would benefit from isolated validation
