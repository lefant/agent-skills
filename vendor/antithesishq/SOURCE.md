# Antithesis skills snapshot

- Source: <https://github.com/antithesishq/antithesis-skills>
- Initial import revision: [`1fd8470d36a9629a75bda4619a5589d679a40d7c`](https://github.com/antithesishq/antithesis-skills/commit/1fd8470d36a9629a75bda4619a5589d679a40d7c)
- Current revision: [`ca4b8fba0991dbaf4b1b57bea9a4b9605725025f`](https://github.com/antithesishq/antithesis-skills/commit/ca4b8fba0991dbaf4b1b57bea9a4b9605725025f)
- Reviewed: 2026-10-28
- License: Apache-2.0, preserved verbatim in [LICENSE](LICENSE).
- Selection: all 12 root-level `antithesis-*/SKILL.md` packages listed in the
  upstream README. The upstream plugin manifest uses `"skills": "./"`, not an
  explicit allowlist. Our updater uses an explicit list so additions need review.
- Local changes: `antithesis-debug/SKILL.md` has trailing whitespace removed and
  a modification notice. All other content across the 88 packaged files, relative
  paths, and executable bits matches upstream. The license is an additional file.
- Excluded: internal test skills, repository test suites,
  CI, install scripts, plugin manifests, and the getting-started website assets.

## CLI migration

Upstream retired `antithesis-agent-browser` and `antithesis-query-logs`. They are
removed with this coordinated refresh, not retained as stale entrypoints.
`antithesis-triage` uses `snouty runs search` for cross-timeline queries;
`antithesis-debug` uses `snouty runs exec` for scripted inspection. Browser
JavaScript, log-processing helpers, and notebook automation are no longer bundled.
Launch examples now use `--launcher`, and Go guidance uses
`antithesis-go-toolexec` instead of the source-transform instrumentor.

## Inventory

Each entry is both the upstream root directory and the local directory under
`vendor/antithesishq/`:

```text
antithesis-debug
antithesis-documentation
antithesis-feature-workload
antithesis-launch
antithesis-mutation-testing
antithesis-research
antithesis-review-inputs
antithesis-setup
antithesis-setup-k8s
antithesis-skills-feedback
antithesis-triage
antithesis-workload
```

`scripts/update-vendor.sh` maps these root directories to the flat vendor layout.
As with other collections, it fetches latest upstream for review; it does not
reproduce this revision. Record a new reviewed revision here when updating.

## Static safety review and operating boundaries

The review inspected package structure, instruction workflows, command and
network-call patterns, and executable helper behavior. It is not a formal audit
or permission to run the workflows. No bundled MCP configuration, hooks,
symlinks, binaries, or automatic installation entrypoints are present. Importing
the collection executes none of its helpers.

- Snouty uses configured tenant credentials. Keep API keys, signed report URLs,
  raw logs, and extracted files private. Use the host's private credential flow;
  never ask for API keys in chat. Triage needs a successful `snouty doctor` check.
- `runs exec` executes shell commands inside a live run or debugging session.
  Confirm the target, moment, and authorized inspection before executing. It can
  perturb the system or trigger assertions; prefer a separate debugging session
  for probes that could contaminate a live run. Each call branches from its
  moment; continue from its returned end moment when state must carry forward.
  A timeout does not prove the script did not run: inspect output before retrying
  state-changing commands. New debugging sessions use core hours; obtain launch
  authorization and ask before cancellation. Do not cancel someone else's run.
- Setup and launch build images and can upload proprietary images/configuration
  and spend run budget. Kubernetes setup applies and deletes resources. Require
  authorization for these effects, use a disposable test cluster, and restrict
  cleanup to task-owned resources. Review generated configuration and use test
  credentials, not production secrets. Local `validate` can start containers.
- Mutation scripts copy a source tree, force-add **gitignored files** into a
  disposable Git repository, reset/clean it, export patches, and delete the
  fork. Review `--source`, `--fork`, `--patches`, exclusions, build contexts,
  bind mounts, and symlinks first. Exclude secrets explicitly: `.gitignore` is
  not an exclusion mechanism here. Marker/path guards are safeguards, not a
  security boundary for untrusted trees. Export wanted patches before cleanup;
  `--force` can discard unexported work. Compose project names do not isolate
  explicit container names or host bind mounts. Confirm the run ceiling and
  concurrency before launching a sweep; mutant runs must stay ephemeral.
- Feedback constructs a GitHub issue URL for user review, rather than submitting
  it. Remove private details before putting them in URL query parameters. In a
  vendor/export installation, use this upstream revision or the skill's embedded
  version rather than the containing repository's `git rev-parse HEAD`.

## Portability and downstream export

- Requires macOS/Linux tooling: Bash, Git, rsync, Python 3, jq, Docker Compose v2
  and a container engine as appropriate. Platform calls need configured Snouty;
  this snapshot requires Snouty 0.8.0+ and debug needs tenant release 64.0+.
  Mutation scripts specifically prefer the standalone `docker-compose` binary.
  Inspect installed CLI help instead of assuming every example matches it.
- Browser automation is no longer required for triage or debugging. If login
  needs interactive consent, use the host's human-visible browser workflow.
- Keep every `assets/` and `references/` subtree intact and resolve relative
  commands against the loaded skill directory. Preserve executable bits: the
  mutation scripts invoke sibling scripts directly. Embedded `AGENTS.md` files
  are templates for generated harnesses, not collection-wide instructions.
- This is an interdependent collection: a single-skill export may need companion
  skills installed. Resolve sibling-skill references against the named package.
- Bare Antithesis skill names refer to this family. A namespaced Amp exporter
  must qualify invocation references consistently, including bundled references
  and templates, without rewriting filesystem paths, CLI flags, or URLs. Avoid
  exposing both bare and namespaced copies to Amp. `agent-browser` itself is a
  separate external skill/tool, not a member to rename into this family.
- Export the Apache-2.0 license with every distribution, including individually
  exported skills; retain upstream notices and mark modified files prominently.
  No upstream `NOTICE` file exists at this revision. Export this provenance too.
  No plugin activation, account configuration, or publication is done here.
- Search results are capped samples, not an exhaustive proof that an event never
  happened. Local checks do not validate the current authenticated platform.

## Verification commands

```sh
./scripts/check-vendor-layout.sh
bash scripts/tests/check-vendor-layout.test.sh
python3 scripts/tests/vendor-safety.test.py -v
bash -n scripts/update-vendor.sh
find vendor/antithesishq -name '*.sh' -exec bash -n {} \;
```

For snapshot verification, compare every selected package path, file byte, and
executable bit plus `LICENSE` to a checkout of the revision above, accounting for
the documented formatting-only patch. Do not run the multi-vendor updater just
to verify this import. The import does not validate
live Snouty, Docker/Kubernetes, authentication, or Antithesis runs.
