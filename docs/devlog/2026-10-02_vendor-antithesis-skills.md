---
date: 2026-10-02
status: ✅ COMPLETED
---

# Vendor the Antithesis skills collection

Prepared the 14 upstream root-level skills at
[1fd8470](https://github.com/antithesishq/antithesis-skills/commit/1fd8470d36a9629a75bda4619a5589d679a40d7c)
as a local vendored collection. All 107 package files and executable bits match
upstream; the Apache-2.0 license is included separately. No skill contents were
modified. An explicit updater allowlist prevents silently importing new skills.
This follows the Matt Pocock import's flat layout and separation from Toolnix's
Amp plugin/export layer.

## Verification

- `scripts/check-vendor-layout.sh`: 91 vendored skills, no name collisions.
- `bash scripts/tests/check-vendor-layout.test.sh`: all cases passed.
- Package byte/path/mode comparison, license comparison, and exact updater
  allowlist comparison passed against the pinned upstream checkout.
- Executed only the new updater block with the existing fetch helpers into a
  temporary directory: all 14 package trees and the license matched this import.
  Unrelated vendors were not refreshed.
- `bash -n`: updater and nine Bash helpers passed. `node --check`: three browser
  helpers passed. Python AST parsing: both helpers passed.
- `build-url.py --test` and `process-logs.py --test`: both reported `all tests passed`.
- Resource scan: 325 local references resolved; the 28 apparent missing local
  references name companion skills in their surrounding text and resolve within
  the collection. Individual exports must account for these dependencies.
- `git diff --cached --check` reports 24 upstream whitespace findings. They are
  retained to keep the imported snapshot byte-identical. Local documentation and
  updater edits pass the whitespace check.

## Review and delivery boundaries

The [source review](../../vendor/antithesishq/SOURCE.md) owns the inventory,
provenance, safety findings, and portability requirements. Important findings:
mutation forks include ignored files; debugger helpers can authorize remote
commands; download scripts check URL paths rather than trusted origins; browser
state and logs can contain credentials or private data. These require use-time
controls, not merely a namespace. No bundled MCP server or automatic hook exists.

No authenticated platform workflow, container build, cluster deployment, or
mutation sweep was exercised. The mutation harness also needs rsync, which is
not installed in this orb. Static review and offline tests are not end-to-end
Antithesis validation.

Prepared locally for the Toolnix parent to transfer and test with a local input
override. No push, PR, plugin activation, or publication is authorized or done.
