---
date: 2026-04-16
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-04-16

**Implementation**: Vendor `mermaid` and `librarian` from `mitsuhiko/agent-stuff` and wire Mermaid guidance to the new validator path

## Summary

Vendored two additional upstream skills from `mitsuhiko/agent-stuff` into the shared `lefant/agent-skills` bundle:

- `vendor/mitsuhiko/mermaid`
- `vendor/mitsuhiko/librarian`

Also updated the custom `lefant/mermaid-diagrams` skill so it explicitly points at the vendored Mermaid validator helper for syntax/render checks while keeping the existing local skill focused on diagram structure and authoring quality.

## What changed

Added:

- `vendor/mitsuhiko/mermaid/`
- `vendor/mitsuhiko/librarian/`
- `docs/devlog/2026-04-16_vendor-mitsuhiko-mermaid-and-librarian.md`

Changed:

- `lefant/mermaid-diagrams/SKILL.md`
- `vendor/README.md`
- `scripts/update-vendor.sh`

## Why

The review of `agent-stuff` showed:

- `mermaid` adds a useful executable validation workflow that the current bundle lacked
- `librarian` is a good fit as a read-only reference-repo cache for agent research work
- the existing custom `mermaid-diagrams` skill remains the better authoring guide, so the right integration is additive rather than replacement

## Notes

The `librarian` skill keeps its upstream cache model:

- `~/.cache/checkouts/<host>/<org>/<repo>`

That is intentionally different from a human-maintained working checkout. It is best treated as agent-side cache state rather than a durable editable repo location.
