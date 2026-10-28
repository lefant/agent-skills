# Vendored Skills

This directory contains skills vendored from upstream repositories. These have been reviewed for security before inclusion.

## Update Process

To update vendored skills:

```bash
./scripts/update-vendor.sh
```

Then review changes before committing:

```bash
git diff vendor/
```

Before a broad refresh or export, read the [2026-10-28 maintenance review](../docs/devlog/2026-10-28_hegel-refresh-vendor-review.md). It records missing upstream paths, destructive updater failure modes, and retirement decisions. A passing layout check does not resolve the remaining issues.

## Layout

Vendored skills are flattened to `vendor/<source>/<skill>/SKILL.md` even when the upstream repository stores them under a `skills/` subdirectory. This keeps wildcard installs from missing nested skills. Use `scripts/update-vendor.sh` as the source-path registry instead of symlinks.

## Sources

| Vendor Directory | Source Repository | Skills |
|-----------------|-------------------|--------|
| `vercel-labs/` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | web-design-guidelines, vercel-react-best-practices |
| `vercel-labs/` | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | agent-browser |
| `vercel/` | [vercel/ai](https://github.com/vercel/ai) | ai-sdk |
| `anthropics/` | [anthropics/skills](https://github.com/anthropics/skills) | frontend-design, skill-creator |
| `humanlayer/` | [humanlayer/skills](https://github.com/humanlayer/skills) | show-me |
| `giuseppe-trisciuoglio/` | [giuseppe-trisciuoglio/developer-kit](https://github.com/giuseppe-trisciuoglio/developer-kit) | shadcn-ui |
| `intellectronica/` | [intellectronica/agent-skills](https://github.com/intellectronica/agent-skills) | context7 |
| `typesafe-ai/` | [typesafe-ai/skills](https://github.com/typesafe-ai/skills) | typesafe-ai |
| `marimo-team/` | [marimo-team/skills](https://github.com/marimo-team/skills), [marimo-team/marimo-pair](https://github.com/marimo-team/marimo-pair) | marimo-notebook, marimo-pair |
| `mitsuhiko/` | [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff) | tmux, librarian |
| `kepano/` | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | json-canvas, obsidian-bases, obsidian-markdown, obsidian-cli, defuddle |
| `ast-grep/` | [ast-grep/agent-skill](https://github.com/ast-grep/agent-skill) | ast-grep |
| `steipete/` | [steipete/agent-scripts](https://github.com/steipete/agent-scripts) | video-transcript-downloader, markdown-converter |
| `dz0ny/` | [dz0ny/devenv-claude](https://github.com/dz0ny/devenv-claude) | devenv |
| `andrewyng/` | [andrewyng/context-hub](https://github.com/andrewyng/context-hub) | get-api-docs |
| `googlecolab/` | [googlecolab/google-colab-cli](https://github.com/googlecolab/google-colab-cli) | operating-colab (upstream: colab-operator) |
| `boldsoftware/` | [boldsoftware/exe.dev](https://github.com/boldsoftware/exe.dev) | using-exe-dev |
| `ChromeDevTools/` | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | chrome-devtools-cli |
| `JuliusBrussee/` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | caveman, caveman-help, caveman-commit, caveman-review, caveman-compress |
| `lambdamechanic/` | [lambdamechanic/skills](https://github.com/lambdamechanic/skills) | zfc |
| `woosal1337/` | [woosal1337/blog](https://github.com/woosal1337/blog) | ste-writing |
| `pulumi/` | [pulumi/agent-skills](https://github.com/pulumi/agent-skills) | pulumi-overview, pulumi-best-practices, pulumi-component, pulumi-automation-api, pulumi-esc, provider-upgrade, package-usage, pulumi-terraform-to-pulumi, pulumi-cdk-to-pulumi, cloudformation-to-pulumi, pulumi-arm-to-pulumi, pulumi-upgrade-provider, upstream-patches, pulumi-neo-handoff |
| `mattpocock/` | [mattpocock/skills](https://github.com/mattpocock/skills) | 27 published engineering and productivity skills; see below |
| `antithesishq/` | [antithesishq/antithesis-skills](https://github.com/antithesishq/antithesis-skills) | 14 Antithesis research, harness, launch, and investigation skills; see [snapshot and review](antithesishq/SOURCE.md) |
| `hegeldev/` | [hegeldev/hegel-skill](https://github.com/hegeldev/hegel-skill) | hegel, hegel-review |
| `DietrichGebert/` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | ponytail |
| `quint-co/` | [quint-co/quint-llm-kit](https://github.com/quint-co/quint-llm-kit) | quint-lang, quint-modeling, quint-execute-spec; see [snapshot and review](quint-co/SOURCE.md) |

### Opt-in / repository-optional skills

The five Caveman skills, ZFC, and all fourteen Pulumi skills remain vendored but
are not general defaults. Their descriptions require an explicit request by name
or repository instructions enabling the skill. Each carries a local scope notice
and `disable-model-invocation: true`; `scripts/update-vendor.sh` reapplies this
policy after refreshes. Enabling one skill does not enable sibling skills or
authorize external changes.

Prefer selected project-local installs. A project can explicitly enable named
skills in its `AGENTS.md` and, if the host requires it for automatic invocation,
remove `disable-model-invocation` from those project-local copies. Keep the
vendored defaults manual-only. Hosts differ in whether they honor this metadata;
the description and body also state the boundary. Wildcard installers still copy
these packages, so use a selected skill list to omit them entirely.

The [Amp publication profile](../docs/reference/amp-skill-publishing.md) excludes
these optional groups by default. This repository does not change installed
skills or separately published plugins; those require their own synchronization.
Caveman defaults to `lite` only after opt-in. Its compression helper still has the
failure-restoration issue recorded in the maintenance review; narrowing its
trigger does not fix that implementation.

### Retired skills

Removed from the tree and updater on 2026-10-28:

- **Anthropic PDF:** its packaged proprietary license prohibits external copying,
  derivatives, and redistribution. Do not reintroduce it without establishing
  redistribution permission. The other Anthropic skills remain included.
- **Remotion:** removed by user choice after review found binary assets unsuitable
  for Amp global skills and redundant packaging. Install separately in a project
  if needed; it is no longer part of this bundle.

Historical Git commits and import logs are unchanged. Removing a package here
does not uninstall existing copies elsewhere.

### Matt Pocock skills

The import matches the 27 skills listed in upstream's plugin manifest at
[v1.3.1 (0b6cee1)](https://github.com/mattpocock/skills/commit/0b6cee10f260a2e048279cf737bfd3e37b1fce0b).
Skill contents and supporting files match upstream except for the two
`implement` inter-skill calls made harness-neutral in `scripts/update-vendor.sh`.
The upstream MIT license is at `mattpocock/LICENSE`. The explicit update lists in
`scripts/update-vendor.sh` exclude unpublished skills, `misc/`, and `in-progress/`;
new upstream skills require review before inclusion. The Claude plugin manifest
itself is not installed.

The v1.3 release graduated `implement-spec`, `pr`, and `retro` and removed
`resolving-merge-conflicts`; all three new skills were already present in this
bundle's earlier d81f3a1 snapshot, and the removed skill was not included.
The skills now read/write `GLOSSARY.md` and, for multiple contexts,
`GLOSSARY-MAP.md` instead of `CONTEXT.md` and `CONTEXT-MAP.md`. Projects using
the old filenames must rename their own files when upgrading; this tooling
repository has no such project-owned files to migrate. Inter-skill invocation
instructions call the Skill tool, rather than relying on slash-command syntax.

- **Engineering:** ask-matt, diagnosing-bugs, grill-with-docs, triage,
  improve-codebase-architecture, setup-matt-pocock-skills, tdd, to-spec, to-tickets,
  wayfinder, implement, implement-spec, prototype, research, domain-modeling,
  codebase-design, code-review, pr, retro, wizard.
- **Productivity:** grill-me, grilling, handoff, teach, to-questionnaire, wait-what,
  writing-for-agents.

Vendoring is not activation. Wildcard installers (including toolnix's current
host-local baseline after its input is updated) expose these as bare names.
An Amp `mp:*` namespace requires a separate directory plugin that registers the
skills; personal-plugin publication is what makes that bundle available across
Amp projects and orbs. Neither is configured here. Exporters must carry the MIT
license into the resulting distribution, including individually exported skills.

For a future `mp` plugin, qualify internal skill calls consistently, preserve
upstream's `disable-model-invocation` flags, and verify how Amp handles them.
Avoid installing both bare and namespaced copies. Namespaces prevent name
collisions, not overlapping triggers or conflicting workflow instructions.
Use fresh threads and explicitly select MP or CE when comparing them; follow each
project's existing document ownership and approval rules. Upstream engineering
flows may require per-project setup; review its proposed instruction/configuration
changes rather than running setup automatically on installation.

## Future sources / optional project-local installs

These sources are not vendored or included in `scripts/update-vendor.sh`. Review
selected skills before installing them locally in a project that needs them.

| Source Repository | Potential Use |
|-------------------|---------------|
| [cloudflare/skills](https://github.com/cloudflare/skills) | Possible future enhancement for Cloudflare API, DNS, rules, TLS, and observability guidance, plus Wrangler workflows. Prefer selected project-local skills over installing the full plugin; skills do not grant API access, and debugging credentials require separate setup. |
| [huggingface/skills](https://github.com/huggingface/skills) | Possible future enhancement for Hugging Face workflows. Review and select project-local skills as needed rather than installing the full collection; authentication and service access require separate setup. |

## Disabled for now

| Vendor Directory | Source Repository | Skills |
|-----------------|-------------------|--------|
| `obra/` | [obra/superpowers](https://github.com/obra/superpowers) | brainstorming, using-superpowers |

Reference: [Steve Yegge, "Zero Framework Cognition: A way to build resilient AI applications"](https://medium.com/@steve-yegge/zero-framework-cognition-a-way-to-build-resilient-ai-applications-56b090ed3e69)

## Security Review

All vendored skills should be reviewed before committing:

1. Check for suspicious commands or network calls
2. Verify skill descriptions match actual behavior
3. Look for hardcoded credentials or sensitive data
4. Review any scripts included with the skill

Note: `vendor/dz0ny/devenv` includes `.mcp.json` pointing to `https://mcp.devenv.sh`. Treat that as part of the review surface when updating the vendored skill.

Note: `vendor/JuliusBrussee/caveman-compress` includes Python scripts that read/write user-selected Markdown files and may call the Anthropic SDK or local `claude` CLI. Review `SECURITY.md` as part of the update.

Note: `vendor/googlecolab/operating-colab` is a self-contained instruction-only skill with no bundled scripts or MCP servers. Its commands install the CLI, authenticate to Google, transfer files, and allocate billable runtimes. Local post-fetch changes rename it and add consent, credential protection, session ownership, and cleanup verification guidance. The Apache-2.0 license travels with the skill. Initial import: [upstream revision](https://github.com/googlecolab/google-colab-cli/commit/465b941001afa3d804fa2094bed763236b72e654).

Note: `vendor/typesafe-ai/typesafe-ai` preserves the official instruction-only skill and MIT license unchanged. It links to live TypeSafe documentation and has no bundled scripts, MCP servers, or credentials. Initial import: [upstream revision](https://github.com/typesafe-ai/skills/commit/65a39f393687675ce170e6094757de20370365b9).

Note: `vendor/mattpocock` was statically reviewed across all 79 bundled files.
It contains no bundled MCP servers, hooks, symlinks, or binaries. Two Bash templates
are included: `diagnosing-bugs/scripts/hitl-loop.template.sh` echoes observations
back to the agent (never use it to capture secrets), and `wizard/template.sh` is
a human-run template that can write `.env` values and GitHub Actions secrets or
variables. Review generated wizards, ensure secret files are ignored by Git, and
obtain authorization before remote writes. Other invoked workflows can edit
project instructions, commit, create worktrees or draft PRs, and update or close
tracker items. Generated architecture reports use third-party CDN scripts.
Importing these files executes none of those actions; this review is not runtime
validation or blanket authorization to run them.

Note: `vendor/antithesishq` preserves 14 skills and their executable helpers
unchanged, with the Apache-2.0 license at the collection root. The
[snapshot review](antithesishq/SOURCE.md) records provenance, prerequisites,
credential and mutation-harness risks, and downstream exporter requirements.
Vendoring does not authorize authentication, remote debug commands, uploads,
cluster operations, or billable runs. No Antithesis service was exercised during
the import; local helper tests are not end-to-end platform validation.

Note: `vendor/hegeldev` contains both instruction-only skills and all seven Hegel
technique guides from [upstream revision 6fd049a](https://github.com/hegeldev/hegel-skill/commit/6fd049a4a1912588c8a6be238d3654ed66a80646)
(plugin v2.1.0), reviewed on 2026-10-28. `hegel-review` and the technique guides
are unchanged. The local `hegel` correction adds Python to the language lists,
documents Python 3.11+ with package `hegeltest` / import `hegel`, and preserves
upstream Python's advice to keep existing Hypothesis suites for ordinary CI.
`scripts/update-vendor.sh` reapplies and checks that correction because the
upstream skill still omits Python. Evidence comes from the
[official Python README](https://github.com/hegeldev/hegel/blob/e356c01953cf7377a8f4463fb2c910fca99b53b3/frontends/python/README.md)
and a local generation/shrinking smoke test with `hegeltest==0.2.1` on Python 3.11.6.
Each skill carries the upstream MIT license for standalone distribution. The
review found no scripts, MCP servers, hooks, binaries, or credential access.
`hegel` references `hegel-review`, so install both. They remain separate from the
Antithesis plugin: these are local property-testing workflows, not hosted test
runs. The broad upstream testing triggers and high-case-count/scale-probe guidance
are preserved, as are v2.1.0's stronger value oracles and mandatory adversarial
subagent review. Host delegation and approval rules still take precedence;
installation does not install a Hegel library or run tests. Updating this vendor
snapshot does not update the separately published Amp User Skills.

Note: `vendor/DietrichGebert/ponytail` preserves the instruction-only core skill
and MIT license unchanged from [upstream revision 16352ac](https://github.com/DietrichGebert/ponytail/commit/16352ac229eb08a9598dcae48fe9f2b342567d86)
(v5.3.2). The reviewed package contains no scripts, MCP servers, hooks, binaries,
network commands, or credential access. Its broad coding-task triggers and
session-long behavior guidance are preserved, with `full` as the default level.
The plugin, lifecycle hooks, band/board, and companion command skills are not
included; installing the skill does not provide automatic per-turn injection.

Note: `vendor/quint-co` preserves the three portable Quint skills, guidelines,
and five `.qnt` example files unchanged. Each skill includes the Apache-2.0
license. No Docker environment, Claude agents/commands, MCP servers, or installers
are imported. The [snapshot review](quint-co/SOURCE.md) records prerequisites and
upstream verification caveats: checking a model alone does not prove application
conformance, and witness predicates must be interpreted according to the selector
used. Vendoring installs neither Quint nor its model-checking backend and does
not publish the skills to Amp User Skills.

## Version Pinning

This repository vendors specific versions of upstream skills. The update script fetches the latest versions - review changes carefully before committing.
