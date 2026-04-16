# Agent Skill Source Map

This file maps the source material used for the repo's skill-authoring guidance.

## 1. Agent Skills Open-Format Docs

External source:

- Repository: `https://github.com/agentskills/agentskills`
- Local working clone convention: `~/git/external/agentskills`
- Snapshot metadata: `lefant/skills-best-practices/references/upstream/agentskills/SOURCE.txt`

Vendored docs snapshot:

- `lefant/skills-best-practices/references/upstream/agentskills/README.md`
- `lefant/skills-best-practices/references/upstream/agentskills/llms.txt`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/what-are-skills.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/specification.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/quickstart.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/best-practices.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/evaluating-skills.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/optimizing-descriptions.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/using-scripts.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/client-implementation/adding-skills-support.mdx`

Vendored reference SDK subset:

- `lefant/skills-best-practices/references/upstream/agentskills/skills-ref/README.md`
- `lefant/skills-best-practices/references/upstream/agentskills/skills-ref/CLAUDE.md`
- `lefant/skills-best-practices/references/upstream/agentskills/skills-ref/pyproject.toml`
- `lefant/skills-best-practices/references/upstream/agentskills/skills-ref/LICENSE`

Use these files for public format details, package layout expectations, description guidance, script usage, and evaluation guidance.

## 2. Existing Local Authoring Skill

Local repo skill:

- `lefant/skills-best-practices/SKILL.md`
- `lefant/skills-best-practices/references/authoring-guide.md`
- `lefant/skills-best-practices/references/spec-quick-reference.md`
- `lefant/skills-best-practices/references/evals-and-iterations.md`
- `lefant/skills-best-practices/references/description-optimization.md`
- `lefant/skills-best-practices/references/scripts.md`
- `lefant/skills-best-practices/assets/skill-template.md`
- `lefant/skills-best-practices/assets/evals-template.json`
- `lefant/skills-best-practices/assets/trigger-evals-template.json`

Use this skill as the default operational guide when creating, reviewing, or refactoring skills in this repo.

## 3. Existing Anthropic Skill Creator Vendor Package

Vendored upstream skill:

- `vendor/anthropics/skill-creator/SKILL.md`
- `vendor/anthropics/skill-creator/references/schemas.md`
- `vendor/anthropics/skill-creator/scripts/`
- `vendor/anthropics/skill-creator/assets/`
- `vendor/anthropics/skill-creator/agents/`
- `vendor/anthropics/skill-creator/eval-viewer/`

Source registry:

- `scripts/update-vendor.sh` fetches `anthropics/skills`, path `skills/skill-creator`, into `vendor/anthropics/skill-creator`.
- `vendor/README.md` lists the source repository and vendored skill inventory.

Use this package as the fuller upstream authoring-and-evaluation workflow reference, especially for:

- skill drafting
- test prompt creation
- with-skill vs baseline comparison
- grading and benchmark loops
- trigger-description optimization

Do not vendor a second copy under `docs/vendor/anthropics/skills/skill-creator`; that duplicates an existing installable skill and reintroduces the nested `skills/` layout this repo avoids.

## 4. Synthesis For This Repo

Primary synthesis doc:

- `docs/reference/agent-skill-authoring-best-practices.md`

Current skill roots:

- `lefant/<skill>/` for in-house skills
- `vendor/<source>/<skill>/` for vendored upstream skills

Relevant repo docs and checks:

- `README.md`
- `vendor/README.md`
- `lefant/skills-best-practices/references/update-upstream-docs.md`
- `scripts/update-vendor.sh`
- `scripts/check-vendor-layout.sh`

## 5. Refresh Instructions

Docs snapshot refresh instructions live in:

- `lefant/skills-best-practices/references/update-upstream-docs.md`

Vendored installable skill refresh instructions live in:

- `vendor/README.md`
- `scripts/update-vendor.sh`

After any vendor change, run:

```bash
./scripts/check-vendor-layout.sh
```
