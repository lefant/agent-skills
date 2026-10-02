# Antithesis skills snapshot

- Source: <https://github.com/antithesishq/antithesis-skills>
- Initial import revision: [`1fd8470d36a9629a75bda4619a5589d679a40d7c`](https://github.com/antithesishq/antithesis-skills/commit/1fd8470d36a9629a75bda4619a5589d679a40d7c)
- Reviewed: 2026-10-02
- License: Apache-2.0, preserved verbatim in [LICENSE](LICENSE).
- Selection: all 14 root-level `antithesis-*/SKILL.md` packages listed in the
  upstream README. The upstream plugin manifest uses `"skills": "./"`, not an
  explicit allowlist. Our updater uses an explicit list so additions need review.
- Local changes to skill packages: none. All 107 bundled files, their relative
  paths, and executable bits are preserved. The license is an additional file.
- Excluded: `.claude/skills/test-triage`, root browser integration test suites,
  CI, install scripts, plugin manifests, and the getting-started website assets.

## Inventory

Each entry is both the upstream root directory and the local directory under
`vendor/antithesishq/`:

```text
antithesis-agent-browser
antithesis-debug
antithesis-documentation
antithesis-feature-workload
antithesis-launch
antithesis-mutation-testing
antithesis-query-logs
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
reproduce this initial revision. Record a new reviewed revision here when updating.

## Static safety review and operating boundaries

The review inspected package structure, instruction workflows, command and
network-call patterns, and executable helper behavior. It is not a formal audit
or permission to run the workflows. No bundled MCP configuration, hooks,
symlinks, binaries, or automatic installation entrypoints are present. Importing
the collection executes none of its helpers.

- Browser JavaScript reads and interacts with the authenticated Antithesis DOM.
  Debug helpers also submit shell commands, extract files, edit notebooks, and
  click action authorization buttons, including `authorizeAll`. Inspect the
  commands and their target before authorizing; do not treat that API as human
  approval. Upstream warns that editing an already-authorized cell can re-run it.
- Browser downloads reuse persisted `antithesis` authentication, accept a URL
  and output path, and can replace an existing output. Their page checks match
  URL paths, not trusted origins. Validate the exact HTTPS tenant origin before
  opening a URL or injecting a runtime. Keep cookies, signed report URLs, raw
  logs, extracted files, and notebook output private. Complete login/MFA through
  the user's browser, not by asking for credentials in chat.
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
  triage requests Snouty 0.6.0+, browser/debug helpers agent-browser 0.23.4+.
  Mutation scripts specifically prefer the standalone `docker-compose` binary.
  Inspect installed CLI help instead of assuming every example matches it.
- Authentication needs an interactive browser when stored state is unavailable.
  A remote orb needs a human-visible browser workflow; a headed local command
  alone does not make a window accessible to the user. The query-logs example
  includes `--no-sandbox`; prefer the host's normal sandboxed browser setup and
  do not copy that flag without an environment-specific reason.
- Keep every `assets/` and `references/` subtree intact and resolve relative
  commands against the loaded skill directory. Preserve executable bits: the
  mutation scripts invoke sibling scripts directly. Embedded `AGENTS.md` files
  are templates for generated harnesses, not collection-wide instructions.
- This is an interdependent collection: some references explicitly belong to
  another Antithesis skill (for example, browser log annotation uses debug's
  `assets/process-logs.py`). Resolve those against the named skill, not the
  current directory; a single-skill export may need companion skills installed.
- Bare Antithesis skill names refer to this family. A namespaced Amp exporter
  must qualify invocation references consistently, including bundled references
  and templates, without rewriting filesystem paths, CLI flags, or URLs. Avoid
  exposing both bare and namespaced copies to Amp. `agent-browser` itself is a
  separate external skill/tool, not a member to rename into this family.
- Export the Apache-2.0 license with every distribution, including individually
  exported skills; retain upstream notices and mark modified files prominently.
  No upstream `NOTICE` file exists at this revision. Export this provenance too.
  No plugin activation, account configuration, or publication is done here.
- Browser selectors and the reverse-engineered Logs Explorer URL format may
  drift. Local helper tests do not validate the current authenticated platform.

## Verification commands

```sh
./scripts/check-vendor-layout.sh
bash scripts/tests/check-vendor-layout.test.sh
bash -n scripts/update-vendor.sh
find vendor/antithesishq -name '*.sh' -exec bash -n {} \;
find vendor/antithesishq -name '*.js' -exec node --check {} \;
python3 vendor/antithesishq/antithesis-query-logs/assets/build-url.py --test
python3 vendor/antithesishq/antithesis-debug/assets/process-logs.py --test
```

For snapshot verification, compare every selected package path, file byte, and
executable bit plus `LICENSE` to a checkout of the revision above. Do not run the
multi-vendor updater just to verify this import. The import does not validate
live Snouty, Docker/Kubernetes, authentication, or Antithesis runs.
