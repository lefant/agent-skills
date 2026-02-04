---
date: 2026-02-04T12:21:52+01:00
researcher: Fabian Linzberger
git_commit: 4764c996d8cde13a0e521f8b5ad2dc22ab8b87e4
branch: main
repository: workspace
topic: "Security review of skills in lefant and vendor"
tags: [research, security, skills]
status: complete
last_updated: 2026-02-04
last_updated_by: Fabian Linzberger
---

# Research: Security review of skills in lefant and vendor

**Date**: 2026-02-04T12:21:52+01:00  
**Researcher**: Fabian Linzberger  
**Git Commit**: 4764c996d8cde13a0e521f8b5ad2dc22ab8b87e4  
**Branch**: main  
**Repository**: workspace

## Research Question
Security review of all skills in `lefant` and `vendor` with brief findings.

## Summary
Observed 8 security-relevant findings across skills and helper scripts, primarily around secret exposure risks, unpinned remote execution, and untrusted remote content consumption.

## Findings
- HIGH: Unpinned, always-fresh remote guidance is fetched and treated as authoritative. ` /workspace/vendor/vercel-labs/web-design-guidelines/SKILL.md:16-29 `
- HIGH: GH_TOKEN exposure risk from printing tokens and passing them in command lines. ` /workspace/lefant/github-access/SKILL.md:18-35 ` ` /workspace/lefant/github-access/references/curl-api.md:10-34 `
- MEDIUM: Sentry fetchers emit request bodies/tags/breadcrumbs without redaction (PII/secret leakage risk). ` /workspace/lefant/sentry/scripts/fetch-issue.js:154-231 ` ` /workspace/lefant/sentry/scripts/fetch-event.js:161-260 `
- MEDIUM: tmux wait helper dumps pane contents on timeout, which may include secrets. ` /workspace/vendor/mitsuhiko/tmux/scripts/wait-for-text.sh:66-78 `
- MEDIUM: Supply-chain execution risks from `uvx --from ...` and `npx ...@latest` with unpinned versions. ` /workspace/lefant/youtube-transcript/SKILL.md:23-44 ` ` /workspace/vendor/giuseppe-trisciuoglio/shadcn-ui/SKILL.md:64-108 ` ` /workspace/vendor/giuseppe-trisciuoglio/shadcn-ui/ui-reference.md:645-653 `
- MEDIUM: Context7 calls send queries to a third-party API without explicit sensitivity guidance. ` /workspace/vendor/intellectronica/context7/SKILL.md:10-38 `
- MEDIUM: Skill packager will include symlink targets during packaging. ` /workspace/vendor/anthropics/skill-creator/scripts/package_skill.py:66-74 `
- LOW: Unquoted file lists in `ctrf-utils.sh` allow word splitting and option-like filenames. ` /workspace/lefant/test-analyzer/ctrf-utils.sh:45-56 `
- LOW: `init_skill.py` does not validate skill name against path separators. ` /workspace/vendor/anthropics/skill-creator/scripts/init_skill.py:205-216 `

## Code References
- ` /workspace/vendor/vercel-labs/web-design-guidelines/SKILL.md:16-29 `
- ` /workspace/lefant/github-access/SKILL.md:18-35 `
- ` /workspace/lefant/github-access/references/curl-api.md:10-34 `
- ` /workspace/lefant/sentry/scripts/fetch-issue.js:154-231 `
- ` /workspace/lefant/sentry/scripts/fetch-event.js:161-260 `
- ` /workspace/vendor/mitsuhiko/tmux/scripts/wait-for-text.sh:66-78 `
- ` /workspace/lefant/youtube-transcript/SKILL.md:23-44 `
- ` /workspace/vendor/giuseppe-trisciuoglio/shadcn-ui/SKILL.md:64-108 `
- ` /workspace/vendor/giuseppe-trisciuoglio/shadcn-ui/ui-reference.md:645-653 `
- ` /workspace/vendor/intellectronica/context7/SKILL.md:10-38 `
- ` /workspace/vendor/anthropics/skill-creator/scripts/package_skill.py:66-74 `
- ` /workspace/lefant/test-analyzer/ctrf-utils.sh:45-56 `
- ` /workspace/vendor/anthropics/skill-creator/scripts/init_skill.py:205-216 `

## Open Questions
None.
