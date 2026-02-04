---
name: architecture-decision-records
description: Create and manage Architecture Decision Records (ADRs) to document significant architectural choices and their rationale.
---

# Architecture Decision Records Skill

Use this skill when creating or working with Architecture Decision Records (ADRs). ADRs capture significant architectural decisions as they emerge during development.

## Purpose

ADRs document the "why" behind architectural choices. They provide context for future developers (including yourself) about decisions made and their tradeoffs. ADRs are meant to be lightweight - capture decisions as they happen, not as ceremony.

## When to Create an ADR

Create an ADR when discussing or deciding:
- Technology selection (database, framework, library choices)
- Significant design tradeoffs
- Architecture patterns (monolith vs microservices, sync vs async)
- API design decisions
- Security approaches
- Performance optimization strategies
- Breaking changes to existing systems

Skip ADRs for:
- Implementation details that don't affect architecture
- Routine code changes
- Temporary workarounds (unless they become permanent)

## Directory Layout

ADRs are stored in `./docs/decisions/` at the project root. Create this directory on demand when writing the first ADR.

## File Naming Convention

`YYYY-MM-DD_short-dash-description.md`

Examples:
- `2026-01-14_use-postgres-for-persistence.md`
- `2026-01-14_adopt-event-sourcing.md`
- `2026-01-15_api-versioning-strategy.md`

## Template

See `template.md` in this skill directory for the ADR format (Nygard style).

## Writing Guidelines

1. **Present tense**: Write as if the decision is being made now
2. **Focus on "why"**: Context and consequences matter more than implementation details
3. **Be brief**: Most ADRs should be under 200 words
4. **Be honest about tradeoffs**: Document what becomes harder, not just what becomes easier

## Immutability

ADRs are immutable once accepted. If a decision needs to change:
1. Create a new ADR with the new decision
2. Set its status to `accepted`
3. Update the old ADR's status to `superseded by YYYY-MM-DD_new-decision.md`

Never edit the Context, Decision, or Consequences of an accepted ADR.

## Status Values

- **proposed**: Decision under discussion
- **accepted**: Decision approved and in effect
- **rejected**: Decision was considered but not adopted
- **deprecated**: Decision is being phased out
- **superseded by YYYY-MM-DD_xxx.md**: Decision replaced by another ADR

## Skill Activation

This skill activates when:
- Discussing architectural choices in conversation
- Making technology selection decisions
- Debating significant design tradeoffs
- Implementing something that contradicts an existing ADR (prompt to supersede)

When activated, suggest running `/adr_create` to capture the decision.

## Cross-Referencing

Reference ADRs from other documentation:
```
See: docs/decisions/2026-01-14_use-postgres-for-persistence.md
```

## Browsing ADRs

Use standard tools to browse existing decisions:
```bash
# List all ADRs chronologically
ls -1 docs/decisions/

# Find ADRs about a topic
grep -l "postgres" docs/decisions/*.md

# Show status of all ADRs
grep "^## Status" docs/decisions/*.md
```

## Creating an ADR

Use the `/adr_create` command:
```
/adr_create "Use PostgreSQL for persistence"
```
