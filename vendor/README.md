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

## Layout

Vendored skills are flattened to `vendor/<source>/<skill>/SKILL.md` even when the upstream repository stores them under a `skills/` subdirectory. This keeps wildcard installs from missing nested skills. Use `scripts/update-vendor.sh` as the source-path registry instead of symlinks.

## Sources

| Vendor Directory | Source Repository | Skills |
|-----------------|-------------------|--------|
| `vercel-labs/` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | web-design-guidelines, vercel-react-best-practices |
| `vercel-labs/` | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | agent-browser |
| `vercel/` | [vercel/ai](https://github.com/vercel/ai) | ai-sdk |
| `anthropics/` | [anthropics/skills](https://github.com/anthropics/skills) | frontend-design, pdf, skill-creator |
| `remotion-dev/` | [remotion-dev/skills](https://github.com/remotion-dev/skills) | remotion-best-practices |
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

### Matt Pocock skills

The import matches the 27 skills listed in upstream's plugin manifest at
[revision d81f3a1](https://github.com/mattpocock/skills/commit/d81f3a183412e71a5b1e84ca21bc1a35eea03a60)
(plugin version 1.2.3). Skill contents and supporting files are unchanged, with
upstream's MIT license at `mattpocock/LICENSE`. The explicit update lists in
`scripts/update-vendor.sh` exclude unpublished skills, `misc/`, and `in-progress/`;
new upstream skills require review before inclusion. The Claude plugin manifest
itself is not installed.

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

## Version Pinning

This repository vendors specific versions of upstream skills. The update script fetches the latest versions - review changes carefully before committing.
