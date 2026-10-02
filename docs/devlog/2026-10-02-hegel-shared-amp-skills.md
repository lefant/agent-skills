---
date: 2026-10-02
status: ✅ COMPLETED
---

# Shared Hegel skills and Amp activation

Vendored `hegel` and its required `hegel-review` companion directly in
`vendor/hegeldev`, separate from the Antithesis hosted-testing plugin. Both skill
bodies and all six technique guides match upstream unchanged; each package
includes the MIT license. The source revision and static security review are in
[`vendor/README.md`](../../vendor/README.md). The update script preserves this
layout and the per-skill licenses.

Published both packages to the user's personal Amp Skills repository and called
`reload_skills`: both names appeared as `global-user`, with no errors. Notified
the [backend testing thread](https://ampcode.com/threads/T-01a0fc8a-1d12-748b-bc68-4003ddaa7cd2)
to reload and use the shared skills rather than install project-local duplicates.
This does not install any language-specific Hegel test library.

Verification:

- Byte comparison of upstream, vendored, and Amp packages: identical, with the
  additional upstream license in each skill (10 files per distribution).
- `bash -n scripts/update-vendor.sh`: passed.
- `scripts/check-vendor-layout.sh`: 93 vendored skills, passed.
- `bash scripts/tests/check-vendor-layout.test.sh`: passed.
- `git diff --check`: passed.

The Amp publication is live. The GitHub `agent-skills` changes remain local
pending push authorization; Toolnix's lockfiles were not changed. Nix consumers
need publication and a later input refresh; Amp activation is independent.
