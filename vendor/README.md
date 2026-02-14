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
| `anthropics/` | [anthropics/skills](https://github.com/anthropics/skills) | frontend-design, skill-creator |
| `remotion-dev/` | [remotion-dev/skills](https://github.com/remotion-dev/skills) | remotion-best-practices |
| `giuseppe-trisciuoglio/` | [giuseppe-trisciuoglio/developer-kit](https://github.com/giuseppe-trisciuoglio/developer-kit) | shadcn-ui |
| `obra/` | [obra/superpowers](https://github.com/obra/superpowers) | brainstorming, using-superpowers |
| `intellectronica/` | [intellectronica/agent-skills](https://github.com/intellectronica/agent-skills) | context7 |
| `mitsuhiko/` | [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff) | tmux |
| `kepano/obsidian-skills/` | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) (subtree) | json-canvas, obsidian-bases, obsidian-markdown |
| `ArtemXTech/` | [ArtemXTech/personal-os-skills](https://github.com/ArtemXTech/personal-os-skills) | tasknotes |
| `ast-grep/` | [ast-grep/agent-skill](https://github.com/ast-grep/agent-skill) | ast-grep |

## Security Review

All vendored skills should be reviewed before committing:

1. Check for suspicious commands or network calls
2. Verify skill descriptions match actual behavior
3. Look for hardcoded credentials or sensitive data
4. Review any scripts included with the skill

## Version Pinning

This repository vendors specific versions of upstream skills. The update script fetches the latest versions - review changes carefully before committing.
