---
date: 2026-09-26
status: ✅ COMPLETED
---

# Project agent resources guide

Extracted [a standalone adoption guide](../reference/adopt-project-agent-resources.md)
from the completed integration reported in the
[implementation thread](https://ampcode.com/threads/T-01a0dce1-6620-706f-91db-b588f79728c6).
Inspected the source runbook, source manifest, refresh implementation, checker,
negative tests and local boundaries at
[the integration revision](https://github.com/lingontuvan-it-group/lingontuvan-stadbokning/commit/1f80261bff29b735941faf0f6537dd8e86fc29aa).
The source was pushed for review, not yet reported merged.

The guide keeps exact-version docs, deliberate platform snapshots, selected
portable skills, pinned provenance and fresh-checkout verification. It does not
copy the source application's backend, release rules, paths or fixed skill list.
The README links it alongside the existing adoption guide. No skills were
installed or changed, and no generic generator is claimed or supplied.

Source review also exposed useful adoption requirements beyond the implementation:
review website redistribution rights, stage replacements, and make text patches
fail if upstream text changes. The guide labels these as requirements rather
than attributing unverified behavior to the original scripts.

Validation: `git diff --check` passed. Focused Python assertions passed for the
README link, balanced code fences, core topic coverage and absence of source
project-specific names/paths in the guide. The source project's reported app and
resource test counts are not presented as tests of this documentation change.

Delivery: prepared for a local documentation commit; no push or PR authorized
for this repository. No deployments or shared-state changes were made.
