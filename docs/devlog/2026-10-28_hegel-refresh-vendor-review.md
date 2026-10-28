---
date: 2026-10-28
status: ✅ COMPLETED
---

# Hegel refresh and vendor maintenance review

The targeted Hegel refresh and general review are complete locally. Following
the user's decisions, Anthropic PDF and Remotion were retired, and Caveman, ZFC,
and all Pulumi skills became opt-in / repository-optional. No other vendor
packages were refreshed. Nothing was committed, pushed, or published to Amp.
Unresolved findings below remain follow-up work.

## Hegel: Python support is real; the upstream skill is stale

Refreshed from `a60b282` to
[`6fd049a4a1912588c8a6be238d3654ed66a80646`](https://github.com/hegeldev/hegel-skill/commit/6fd049a4a1912588c8a6be238d3654ed66a80646)
(plugin v2.1.0). The update adds value-pinning oracles and a seventh technique
guide for mandatory independent subagent review. That requirement is preserved,
subject to the host's delegation rules. `hegel-review` has no upstream changes.

The current upstream skill still excludes Python from both language lists.
The official implementation's
[Python README](https://github.com/hegeldev/hegel/blob/e356c01953cf7377a8f4463fb2c910fca99b53b3/frontends/python/README.md),
project metadata, and [PyPI 0.2.1 metadata](https://pypi.org/pypi/hegeltest/0.2.1/json)
confirm Python 3.11+, package `hegeltest`, and import `hegel`. The README advises
retaining Hypothesis for ordinary CI, especially existing Hypothesis suites;
Hegel is preferred for Antithesis workloads but also runs locally without an
account. Added this guidance and Python discovery locally, with reproducible
post-fetch replacements and required-snippet checks in the existing updater.
Both MIT licenses are retained.

Verification:

- A disposable Python test used `@hegel.test(test_cases=1000, derandomize=True,
  database="")` and generated integer lists. A `Counter` comparison checked
  duplicate preservation independently of sorting order.
- On Python 3.11.6 / `hegeltest==0.2.1`, the deliberately broken
  `sorted(set(values))` implementation failed and shrank to `values = [0, 0]`.
  The `sorted(values)` control passed all 1,000 generated cases.
- Invocation: `uv run --no-project --python 3.11 --with hegeltest==0.2.1 --with
  pytest python -m pytest -q -s -p no:cacheprovider <temporary-test>`. Temporary
  tests and logs were removed; no Python dependency was added to this repository.
- Applying the actual post-fetch block to upstream Hegel files in a disposable
  vendor copy reproduced the checked-in packages. Hegel-only second-run
  idempotence and intentional language-list drift rejection passed.
- Every other Hegel file and both licenses match the upstream snapshot byte for
  byte. All seven referenced technique guides are included.
- `bash -n scripts/update-vendor.sh`, `scripts/check-vendor-layout.sh` (97 skills),
  `bash scripts/tests/check-vendor-layout.test.sh`,
  `scripts/check-show-me-vendor.py`, `scripts/check-ste-lint.sh`, and
  `git diff --check` passed.

This verifies packaging and Python generation/shrinking, not all language
frontends or an end-to-end agent evaluation of the new review workflow.

## General pass: 97 skills, 29 upstream repositories before retirement

Mapped every vendored entrypoint through `scripts/update-vendor.sh`. Fetched each
repository's HEAD SHA, then compared revision-pinned raw `SKILL.md` files with
local entrypoints, accounting for the updater's existing local patches.
After the Hegel refresh: **51 matched, 43 differed, and 3 mapped paths were
missing**. Differences include metadata-only changes; they are not all bugs.
Supporting resources were not exhaustively compared to upstream, so a matching
entrypoint does not establish whole-package freshness.

The static corpus review covered all frontmatter and read or sampled every
entrypoint, with focused inspection of referenced helpers and resources. Layout
and name uniqueness passed. This was not an exhaustive script security review,
usage analysis, or runtime validation of all 97 skills.

### Upstream migrations to handle deliberately

- **Antithesis:** upstream
  [84b188a](https://github.com/antithesishq/antithesis-skills/commit/84b188af8cde10a5babd0fdb15094910a425e36a)
  removed `antithesis-agent-browser` and `antithesis-query-logs`.
  `snouty runs search` in triage and `snouty runs exec` in debug replace them.
  The current collection requires Snouty 0.8.0+; debug also requires tenant
  release 64.0. Refresh the collection and remove the two skills together,
  rather than deleting dependencies from the old snapshot in isolation.
- **STE:** the three old `videos/ep01-the-cure-for-ai-slop/ste-*` mappings moved
  under [`asd-ste100/`](https://github.com/woosal1337/blog/tree/2998d792776fb7e681fbd41e1edca85032d39c10/videos/ep01-the-cure-for-ai-slop/asd-ste100).
  The new name is `asd-ste100`; its v2 guidance adds always-on reply shaping
  and assumes the reader has ADHD. This is a behavior decision, not just a path
  repair. Keep the current snapshot until that choice is made.
- **Chrome DevTools CLI:** current upstream examples add explicit page IDs,
  change positional arguments/flags, and describe full filesystem access as the
  default. Refresh against the installed CLI, not by assuming old calls work.
- **Other review priorities:** substantial body changes in TypeSafe, marimo-pair,
  and frontend-design; eleven Matt Pocock entrypoints differ. Agent-browser's
  entrypoint change only adds a protected-Vercel-deployment guide. These packages
  were not modified in this pass.

### Safety and packaging findings

1. **PDF redistribution — retired:** the former
   `vendor/anthropics/pdf/LICENSE.txt`
   prohibits copying outside Anthropic's services, derivative works, and
   distribution. The upstream license was identical when reviewed. The user chose
   retirement; the entire package and updater entry are removed. Do not restore
   it without establishing permission.
   Separate contractual permissions were not investigated. Sixteen of the other
   26 source directories reviewed contain no LICENSE/COPYING file; that proves
   missing packaged notices, not absence of upstream licensing permission.
2. **Updater loses snapshots:** `fetch_skillset` deletes each target before
   checking that the source exists. The Pulumi block deletes its whole directory
   before any successful fetch. Calls swallow failures with `|| true`, and the
   layout checker does not enforce the expected inventory. The two removed
   Antithesis paths make this a current risk, not a hypothetical one. Stage and
   validate replacements before deleting existing snapshots.
3. **Librarian traversal, reproduced:**
   [`checkout.sh`](../../vendor/mitsuhiko/librarian/checkout.sh) accepts `..`
   components, constructs a path outside its cache, and rewrites a preexisting
   checkout's `origin`. A disposable Git repository plus
   `LIBRARIAN_CACHE_ROOT=<temp>/cache` and input
   `https://github.com/../../victim` demonstrated the origin rewrite outside the
   cache. A fresh last-fetch marker prevented any network fetch. No real checkout
   was touched. Validate components and resolved cache containment before writes.
4. **Caveman compression:**
   [`compress.py`](../../vendor/JuliusBrussee/caveman-compress/scripts/compress.py)
   writes the candidate before validation. An exception in a repair request can
   leave invalid content live; a backup remains, but restoration only happens on
   the normal retry-exhaustion path. This was a source inspection, not a live API
   test. Separately, the command post-fetch patch repeated `cd {baseDir} &&` on
   every application. That patch now matches the whole command line, preserving
   idempotence while applying the new opt-in policy. This does not repair the
   compression helper's failure-restoration behavior.
5. **Devenv:** troubleshooting recommends deleting PostgreSQL/Redis state for
   cleanup without establishing disposability or backup. Its `.mcp.json` also
   does not match Amp's documented `mcp.json` / inline format, despite claiming
   automatic setup. Add data-loss boundaries and host-aware configuration.
6. **Portability:** Mitsuhiko's tmux instructions mix `-S` and `-L`, while the
   wait helper queries the default server. Terraform-to-Pulumi mandates MCP
   tools without configuring them or providing a CLI fallback, and does not
   clearly branch around imports for source-only migration.
7. **Quint:** known model-vs-implementation and witness-selector caveats live in
   [`SOURCE.md`](../../vendor/quint-co/SOURCE.md), outside individually exported
   skills. Put operative qualifications into the affected skill before exporting.
8. **Remotion — retired:** the reviewed snapshot contained 13 PNGs, incompatible
   with Amp's text-only global skill packaging, and 44 redundant exact-copy files
   (508,311 bytes). The user chose removal rather than a custom export. All 137
   files, the updater entry, and Remotion-specific post-fetch patches are removed.
   Disk bytes are not equivalent to loaded context tokens.

## Retirement decisions and remaining recommendations

| Candidate | Disposition |
| --- | --- |
| Anthropic PDF | Retired locally at the user's request; updater mapping removed. |
| Antithesis browser and query-logs | Retire with the coordinated Snouty-based collection refresh. |
| Caveman family | All five skills are now opt-in; ordinary brevity, commit, review, and compression requests no longer activate them. Compression still needs repair. |
| ZFC | Now opt-in and scoped to projects explicitly adopting its architecture. |
| Pulumi | All fourteen skills are now opt-in / repository-optional, following the user's broader Pulumi decision. |
| Remotion | Retired locally at the user's request; updater mapping removed. |

All twenty optional skills have scoped descriptions, a local policy notice, and
`disable-model-invocation: true`. The existing updater reproduces these changes.
The policy also gates sibling-skill references; loading an overview is not consent
to load the whole family or perform external writes. Host support for manual-only
metadata varies. Selected project-local copies can enable automatic invocation
when the project explicitly chooses it.

The root usage note and Amp publication recipe now distinguish wildcard copying
from activation. The default Personal Skills profile excludes optional groups
and no longer selects PDF. No installed copy or hosted skill repository changed;
future authorized publication must follow the existing ownership manifest before
removing previously managed skills. Historical import logs and Git history remain.

Follow-up verification:

- `scripts/check-vendor-layout.sh` reports **95 skills** after retirement; shell
  syntax, layout regression tests, show-me checks, STE checks, and `git diff
  --check` pass.
- A disposable `uv run --no-project --with pyyaml python` check parsed all twenty
  optional frontmatters, checked the eighteen-entry default vendor publication
  profile, and confirmed both retired packages and fetch mappings are absent.
- Restoring pre-policy files in a temporary vendor tree and running the actual
  post-fetch phase reproduced the entire current vendor tree byte for byte.
  A second run changed no bytes. Removing a description or renaming a skill
  caused the policy phase to fail as intended. Temporary fixtures were removed.
- Local documentation links resolve. No live host trigger evaluation, Pulumi
  operation, compression API call, full network refresh, or publication was run.

Do not delete the Matt Pocock or Antithesis vendor snapshots merely because Amp
plugins exist: other hosts consume them. Instead, ensure Amp exporters avoid
bare/namespaced duplication. The separately installed `mp:*`, `antithesis:*`,
and `ce:*` plugins were not audited or updated here. Context7/get-api-docs and
agent-browser/Chrome DevTools overlap calls for a default and explicit fallback,
not automatic deletion without usage evidence.

Recommended follow-up order: repair updater/cache write safety; migrate Antithesis
together; decide STE v2; then refresh remaining retained packages in reviewable
groups. GitHub publication, Amp User Skills activation, and plugin updates remain
separate actions.
