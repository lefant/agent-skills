---
name: expect-testing
description: Creates and reviews expect tests, inline snapshots, approval tests, and golden files. Use when adding exact-output regression tests or investigating snapshot mismatches. Not for Tcl Expect automation or ordinary expect() assertions.
---

# Expect Testing

Treat snapshots as reviewed specifications, not generated cache. Capturing actual
output does not establish that it is correct.

## Choose the expectation

- Reuse the project's runner and snapshot conventions. For small outputs, prefer
  inline expectations: Python's `inline_snapshot.snapshot()` or Vitest/Jest's
  `toMatchInlineSnapshot()`. Use external golden files for larger readable artifacts.
- Snapshot observable behavior: diagnostics, CLI output, serialized values, or
  generated documents. Keep each expectation small enough to review in full;
  use ordinary assertions when only a value or invariant matters.
- Make inputs deterministic first: control clocks, randomness, and fixtures.
  Normalize only incidental timestamps, IDs, paths, or ordering. Preserve fields
  and order that are part of the contract; scrubbing them would hide regressions.

## Review loop

1. Read the affected tests and runner configuration. Check the installed version's
   help for generation, update, and strict no-write modes; defaults and flags vary.
   Run the affected tests without writing expectations and inspect any failures.
2. **New test:** generate a candidate expectation only for the test you added.
   Read the entire output and check it against the requested behavior or an
   independently reasoned example before keeping it.
3. **Existing expectation:** inspect the old/new diff before accepting a change.
   Every material difference must follow from the requested behavior change.
   If it does not, fix the implementation or test setup rather than blessing the
   output. If the intended contract is unclear, ask before changing the baseline.
4. Apply only reviewed changes, scoped by test file and test name where supported.
   Inspect the resulting source/artifact diff for unrelated rewrites. Never use
   a suite-wide update as a generic response to failing tests.
5. After every write-enabled run, rerun the affected tests in strict no-write
   mode: missing or changed expectations must fail, not be created or accepted.
   Repeat the check when introducing normalization to confirm stable output.
   Keep CI in no-write mode too.

Report which expectations were added or changed, the semantic reason for each
existing change, any normalization introduced, and the strict verification result.
