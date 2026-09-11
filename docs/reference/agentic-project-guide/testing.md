# Test the behavior and record what the evidence proves

Choose layers by risk. Separate fast, credential-free checks from tests requiring
services or shared resources. Command names such as `test:unit`,
`test:integration`, and `test:e2e` are illustrative; use the project's equivalents.

| Layer | Useful evidence | Important limit |
|---|---|---|
| Unit | Local rules, boundaries, and failure paths | Replaced dependencies are not verified |
| Integration | Real collaboration across a module, storage, or service boundary | Only the exercised boundary is covered |
| Scripted end-to-end | Repeatable critical journeys through the actual system | A small smoke suite is not exhaustive |
| Interactive exploration | Unexpected behavior, usability, and visual states | Does not replace repeatable regression tests |

Integration tests can be in-process; they need not call cloud services. For a CLI
or library, end-to-end checks should exercise its public interface rather than a
browser. State which dependencies each suite replaces. Promote repeatable
exploratory discoveries to the cheapest automated layer that catches the bug.

## Pick inputs that distinguish correct from plausible wrong behavior

- Derive expected values independently from requirements, not the implementation.
  Use asymmetric inputs, invalid cases, and both sides of meaningful boundaries.
- Assert outputs, persisted writes, errors, and forbidden side effects. Call counts
  alone rarely establish correctness.
- Control time throughout fixture creation and verification. Cover expiry edges
  and relevant timezone/DST boundaries; restore clocks and global state afterward.
- Exercise the real authorization guard with allowed and denied requests. A hidden
  button, route redirect, or mocked guard does not prove mutation authorization.
- Where applicable, test validation before writes, conflicts, duplicate requests,
  partial failures, and cleanup. Disabled buttons do not prevent concurrent writes.
- Prefer the actual application client. If a test must use a separate protocol
  client, document its limits and check contracts against independent expectations;
  it cannot prove frontend wiring, caching, or rendering.

Make test prerequisites reproducible. Commands should establish or validate the
required environment rather than depend on somebody running another suite first.
Do not hide resets or deployments inside apparently read-only commands: name their
effects and require the target's authorization.

## Browser checks need observable outcomes

Run the actual application for critical browser journeys. Use a production build
when verifying build-dependent release behavior. Select relevant journeys: public
navigation, a backend-backed read, denied and permitted access, a critical mutation
followed by a persisted read, and validation/empty/error/conflict states.

Use role/label selectors where possible and bounded waits for observable state.
With snapshot-based agent tools, acquire fresh element references after rerenders
or navigation. After a timeout, inspect whether a write already completed before
retrying it. Use separate sessions when testing competing users.

Do not substitute API writes for the UI journey under test. Independent reads can
corroborate persistence. Verify cleanup and subsequent UI/cache convergence.
For appearance changes, capture and inspect representative rendered states;
capturing alone is not verification. For interaction changes, assert behavior and
relevant DOM or accessibility outcomes.

Use a short written scenario for human or agent exploration:

```text
Purpose and acceptance criteria:
Environment/revision and prerequisites:
Roles, safe fixtures, and resource ownership:
Permitted mutations and cleanup:
Steps: action -> observable expectation:
Independent cross-check, where needed:
Relevant visual states and viewport sizes:
Result: pass / fail / blocked, with sanitized evidence:
Cleanup result and remaining shared-state changes:
```

Load the chosen browser tool's current instructions. Keep manual login/MFA
checkpoints available when needed; never put reusable auth state in test artifacts.

## Use safe data and report coverage honestly

Use isolated test environments; avoid sharing mutable test environments between
independent runs or developers.

Prefer disposable deterministic synthetic fixtures. Production-derived data needs
explicit approval, minimization, sanitization, controlled access and retention,
and blocked outbound effects such as email, payments, or webhooks. Sanitizing names
alone does not establish that a dataset is safe. Never reset production for tests.

If required fixtures are missing, safely create them within authorization or report
the scenario blocked. Do not weaken assertions to fit incidental data.

Record commands, revision/environment, decisive results, skipped or blocked cases,
and cleanup status. Missing credentials do not count as a passed integration test.
Preserve command exit status when piping output. Sanitize logs, screenshots, and
traces before sharing; keep credentials, personal data, and browser sessions out
of repository history and ordinary CI artifacts.
