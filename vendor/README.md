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

## Sources

| Vendor Directory | Source Repository | Skills |
|-----------------|-------------------|--------|
| `vercel-labs/` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | web-design-guidelines, vercel-react-best-practices |
| `vercel-labs/` | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | agent-browser |
| `vercel/` | [vercel/ai](https://github.com/vercel/ai) | ai-sdk |
| `anthropics/` | [anthropics/skills](https://github.com/anthropics/skills) | frontend-design, pdf, skill-creator |
| `remotion-dev/` | [remotion-dev/skills](https://github.com/remotion-dev/skills) | remotion-best-practices |
| `giuseppe-trisciuoglio/` | [giuseppe-trisciuoglio/developer-kit](https://github.com/giuseppe-trisciuoglio/developer-kit) | shadcn-ui |
| `intellectronica/` | [intellectronica/agent-skills](https://github.com/intellectronica/agent-skills) | context7 |
| `mitsuhiko/` | [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff) | tmux, mermaid, librarian |
| `kepano/obsidian-skills/` | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) (subtree) | json-canvas, obsidian-bases, obsidian-markdown, obsidian-cli, defuddle |
| `ArtemXTech/` | [ArtemXTech/personal-os-skills](https://github.com/ArtemXTech/personal-os-skills) | tasknotes |
| `ast-grep/` | [ast-grep/agent-skill](https://github.com/ast-grep/agent-skill) | ast-grep |
| `steipete/` | [steipete/agent-scripts](https://github.com/steipete/agent-scripts) | video-transcript-downloader, markdown-converter |
| `openclaw/` | [openclaw/skills](https://github.com/openclaw/skills) | tavily-search |
| `dz0ny/` | [dz0ny/devenv-claude](https://github.com/dz0ny/devenv-claude) | devenv |
| `andrewyng/` | [andrewyng/context-hub](https://github.com/andrewyng/context-hub) | get-api-docs |
| `boldsoftware/` | [boldsoftware/exe.dev](https://github.com/boldsoftware/exe.dev) | using-exe-dev |
| `ChromeDevTools/` | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | chrome-devtools-cli |
| `JuliusBrussee/` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | caveman, caveman-help, caveman-commit, caveman-review, caveman-compress |

## Disabled for now

| Vendor Directory | Source Repository | Skills |
|-----------------|-------------------|--------|
| `obra/` | [obra/superpowers](https://github.com/obra/superpowers) | brainstorming, using-superpowers |

## Security Review

All vendored skills should be reviewed before committing:

1. Check for suspicious commands or network calls
2. Verify skill descriptions match actual behavior
3. Look for hardcoded credentials or sensitive data
4. Review any scripts included with the skill

Note: `vendor/dz0ny/devenv` includes `.mcp.json` pointing to `https://mcp.devenv.sh`. Treat that as part of the review surface when updating the vendored skill.

Note: `vendor/JuliusBrussee/caveman-compress` includes Python scripts that read/write user-selected Markdown files and may call the Anthropic SDK or local `claude` CLI. Review `SECURITY.md` as part of the update.

## Version Pinning

This repository vendors specific versions of upstream skills. The update script fetches the latest versions - review changes carefully before committing.
