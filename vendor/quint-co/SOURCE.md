# Quint skills snapshot

- Source: <https://github.com/quint-co/quint-llm-kit>
- Initial import revision: [`cc75369f741af7d490936f82002c2d28e3b3d78d`](https://github.com/quint-co/quint-llm-kit/commit/cc75369f741af7d490936f82002c2d28e3b3d78d)
- Reviewed: 2026-10-24
- Selection: `quint-llm-kit-plugin/skills/{quint-lang,quint-modeling,quint-execute-spec}`.
- Local mapping: `vendor/quint-co/<skill>/`, preserving all 21 upstream files,
  relative paths, and file modes unchanged.
- License: upstream Apache-2.0 `LICENSE`, added verbatim to each skill for
  standalone distribution. No root-level upstream `NOTICE` file is present.
- Excluded: Docker/Foundry environments, Claude agents and slash commands,
  plugin manifests, MCP servers, installation scripts, and the larger KB corpus.

`scripts/update-vendor.sh` explicitly selects these three skills and their
licenses. Like the other vendor mappings, it fetches latest upstream for review,
not this initial revision. Record a new reviewed revision here after an update.

## Static safety review

The selected packages contain Markdown guidance and five Quint example files.
Inspection of file types and command/integration references found no bundled
shell helpers, MCP configurations, hooks, symlinks, binaries, credential access,
or upload commands. Importing these packages executes nothing.

The CLI reference includes a global npm installation command and describes
Quint's automatic Apalache download/start behavior. Installing the skills does
not install these dependencies or authorize those actions. Prefer the target
environment's pinned dependency setup; follow its installation and approval
rules. Generated models, traces, and implementation changes can contain private
project information and should stay within the user's requested scope.

## Prerequisites and portability

- Install all three together: modeling and implementation refer to the language
  skill, and modeling has sibling-relative links to its guidelines.
- Keep every `guidelines/` and `examples/` subtree intact. The Tendermint example
  includes its Choreo and `basicSpells` imports; no external KB checkout is needed
  to resolve those imports. KB paths in the examples README describe provenance.
- Requires the Quint CLI (`@informalsystems/quint`). Upstream's example README
  records Quint 0.32.0 as its last verified version; this import does not pin or
  install the executable. `quint verify` additionally needs Java/Apalache.
- No Docker, Claude Code, MCP server, or Amp-specific plugin is required for this
  portable path. No Toolnix inputs or Amp User Skills publication are changed.

## Known upstream verification caveats

The instructions remain unchanged, including these limitations:

- `quint-execute-spec` uses model runs as implementation gates. Re-running an
  unchanged model after application edits does not establish application/model
  conformance. Application tests or model-based conformance tests must connect
  the implementation to the model before claiming that evidence.
- That skill mixes positive witnesses selected with `--witnesses` and negated
  reachability predicates selected as invariants. A positive witness succeeds
  when reached; a negated target used as an invariant succeeds as a reachability
  check when violated. Do not treat every witness violation as success, or every
  zero sampled hit count as proof of unreachability.
- `quint run` is sampled simulation, not exhaustive verification. `quint verify`
  checks a bounded model, not arbitrary production executions. Report the model
  assumptions, bounds, coverage, and implementation evidence separately.

## Import validation

Compare every selected file and file mode to the revision above, and each
per-skill license to its root `LICENSE`. Run:

```sh
bash -n scripts/update-vendor.sh
./scripts/check-vendor-layout.sh
bash scripts/tests/check-vendor-layout.test.sh
git diff --check
```

This is packaging/static validation, not a runtime evaluation of the skills,
the `.qnt` examples, Quint, or Apalache. Do not run the multi-vendor updater just
to validate this import; it refreshes unrelated collections too.

The initial snapshot retains six trailing-whitespace lines and an extra blank
line at EOF in `quint-modeling/examples/tendermint/tendermint.qnt`.
`git diff --check` reports these seven upstream warnings on import; they are
preserved deliberately so the selected upstream files remain byte-identical.
