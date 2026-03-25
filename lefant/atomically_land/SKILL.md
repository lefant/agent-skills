---
name: atomically_land
description: Land a finished implementation cleanly by updating plans and issues, reviewing specs and ADRs, writing session docs, creating changelog fragments when appropriate, and preparing handover context.
---

# Atomically Land

Use this skill when the user wants to wrap up a feature, fix, or refactor and make sure the surrounding documentation and tracking are in order.

This skill is the replacement for the old `atomically_land` command.

## Scope

Use it when the user asks to:
- "`atomically_land`"
- finish landing a change
- make sure docs and tracking are up to date
- close out a session cleanly
- prepare work for handoff after implementation

## Workflow

1. Verify implementation and tests are committed or ready to commit
2. Update tracking artifacts:
   - implementation plan checkboxes
   - issue trackers such as beads or GitHub issues
3. Review related specs in `docs/specs/`
   - if the implementation changed the intended behavior, update the spec
4. Review whether architectural decisions emerged
   - if yes, use `architecture-decision-records`
5. Write a devlog or WIP devlog using `devlog`
6. For significant work, create a changelog fragment using `changelog-fragments`
7. Commit the documentation updates when the user wants commits made
8. Generate a handover prompt when useful using `handover`

## When to Create Related Artifacts

Create or update a spec when:
- the implemented behavior materially differs from the current spec
- the session clarified missing requirements

Create an ADR when:
- a meaningful design decision was made during implementation
- the implementation establishes a new technical standard or tradeoff

Create a changelog fragment when:
- the work is a meaningful feature, fix, refactor, docs change, test improvement, or perf change

## Output

Summarize:
- what was landed
- what docs or tracking were updated
- any remaining WIP
- the next logical task
