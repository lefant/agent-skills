---
date: 2026-10-02
status: ✅ COMPLETED
---

# Vendor Matt Pocock's published skills

Imported the 27 packages declared by upstream's v1.2.3 plugin manifest at
[d81f3a1](https://github.com/mattpocock/skills/commit/d81f3a183412e71a5b1e84ca21bc1a35eea03a60).
All 79 bundled files are byte-identical to upstream. The MIT license is included
at the vendor root. Experimental/miscellaneous and other unlisted skills are
excluded. The update registry explicitly maps both upstream categories to flat
`vendor/mattpocock/<skill>` paths; unrelated vendors were not refreshed.

## Verification

- `scripts/check-vendor-layout.sh`: 77 vendored skills, no name collisions.
- `bash scripts/tests/check-vendor-layout.test.sh`: all cases passed.
- Byte comparison against the upstream manifest: all 27 packages and 79 files
  match, license matches, and updater mappings cover exactly the same packages.
- `bash -n` passed separately for the updater and both imported Bash templates.
- Static package review found no bundled MCP servers, hooks, binaries, or
  symlinks. Runtime workflows and generated scripts were not exercised.
- Code review: skipped (mechanical diff) — verbatim upstream snapshot plus
  declarative source mappings and documentation; package safety reviewed separately.

## Amp integration remains separate

The user wants to compare MP and CE in different projects or threads. A future
toolnix exporter should register this set as an Amp `mp` directory plugin, qualify
internal skill references, include the license, and avoid duplicate bare-name
installation. Verify Amp's handling of upstream's manual-invocation flags.
Namespacing does not isolate active instructions; fresh threads are preferable
for comparison. See `vendor/README.md` for setup and use-time security cautions.

No toolnix inputs were updated and no global skills or plugins were published.
