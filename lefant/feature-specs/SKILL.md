---
name: feature-specs
description: Create and manage feature specifications that capture WHAT a feature does and WHY, without prescribing HOW to implement it.
---

# Feature Specs Skill

Use this skill when creating or working with feature specifications. Feature specs capture intent (WHAT and WHY) before implementation begins.

## Purpose

Feature specs define what a feature should do and why it matters, without prescribing how to implement it. They serve as contracts between stakeholders and developers, and as living documentation that evolves with the product.

## When to Create a Spec

Create a feature spec when:
- Starting work on a new feature
- Clarifying requirements before implementation
- Documenting expected behavior for testing
- Aligning stakeholders on feature scope

Skip specs for:
- Bug fixes (unless behavior is unclear)
- Routine maintenance
- Implementation details (those go in ADRs)

## Directory Layout

Specs are stored in `./docs/specs/` at the project root. Create this directory on demand when writing the first spec.

## File Naming Convention

`<feature-name>.md` - lowercase, dash-separated

Examples:
- `user-authentication.md`
- `export-to-csv.md`
- `rate-limiting.md`

## Template

See `template.md` in this skill directory for the spec format.

## Writing Guidelines

### Focus on WHAT, not HOW

- **Good**: "The system SHALL validate email format before submission"
- **Bad**: "The system SHALL use a regex to check emails"

Implementation decisions belong in ADRs, not specs.

### Use Normative Language

- **SHALL**: Required behavior (must have)
- **SHOULD**: Recommended behavior (should have)
- **MAY**: Optional behavior (nice to have)

### Write Scenarios in GIVEN/WHEN/THEN

```
GIVEN a user is logged in
WHEN they click "Export"
THEN a CSV file downloads containing their data
```

Include error scenarios:
```
GIVEN invalid credentials
WHEN user attempts login
THEN system displays error message without revealing which field is wrong
```

### Keep It Brief

- Purpose: 1-2 sentences
- Requirements: One SHALL/SHOULD/MAY statement each
- Scenarios: 2-4 per requirement (happy path + key edge cases)
- Aim for scannable, not exhaustive

### Embrace Open Questions

Open Questions are first-class citizens, not failures. It's better to document uncertainty than to guess:

```markdown
## Open Questions
- [ ] Should rate limiting apply per-user or per-API-key?
- [ ] What's the acceptable latency for export operations?
```

Resolve questions before or during implementation, then update the spec.

## Living Documents

Specs evolve. When reality diverges from the spec:
1. Update the spec to match the new understanding
2. Use git history to track how requirements changed
3. Don't maintain outdated specs—they become misleading

Changes are managed via git branches, not versioned filenames.

## Relationship to ADRs

| Specs | ADRs |
|-------|------|
| WHAT the system does | WHY we chose this approach |
| Behavior and intent | Implementation decisions |
| User-facing requirements | Technical tradeoffs |
| Living documents | Immutable records |

Cross-reference when relevant:
```
See: docs/decisions/2026-01-14_use-postgres-for-persistence.md
```

## Skill Activation

This skill activates when:
- Discussing new features in conversation
- Planning work before implementation
- Clarifying requirements or expected behavior
- User asks "what should this do?" or "how should this behave?"

When activated, suggest running `/spec_create` to capture requirements.

## Creating a Spec

Use the `/spec_create` command:
```
/spec_create "user authentication"
```
