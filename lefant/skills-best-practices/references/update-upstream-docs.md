# Updating Upstream Reference Docs

This skill vendors the public Agent Skills documentation it depends on under:

- `references/upstream/agentskills/`

That keeps `skills-best-practices` self-contained after deployment. Do not rely on repo-level `docs/` paths for material the skill needs at runtime.

## Refresh `agentskills` docs snapshot

From the `skills-best-practices` skill root, run:

```bash
./scripts/update-agentskills-docs.sh
```

The script:

1. clones or updates `https://github.com/agentskills/agentskills`
2. stores the clone at `${AGENTSKILLS_CLONE_DIR:-$HOME/git/external/agentskills}`
3. fetches `https://agentskills.io/llms.txt`
4. copies the curated documentation subset into `references/upstream/agentskills/`
5. rewrites `references/upstream/agentskills/SOURCE.txt` with the source commit and fetch date

To use a different clone location:

```bash
AGENTSKILLS_CLONE_DIR=/tmp/agentskills ./scripts/update-agentskills-docs.sh
```

## Curated files

The refresh script vendors:

- `README.md`
- `llms.txt`
- `docs/what-are-skills.mdx`
- `docs/specification.mdx`
- `docs/skill-creation/quickstart.mdx`
- `docs/skill-creation/best-practices.mdx`
- `docs/skill-creation/evaluating-skills.mdx`
- `docs/skill-creation/optimizing-descriptions.mdx`
- `docs/skill-creation/using-scripts.mdx`
- `docs/client-implementation/adding-skills-support.mdx`
- `skills-ref/README.md`
- `skills-ref/CLAUDE.md`
- `skills-ref/pyproject.toml`
- `skills-ref/LICENSE`

## Verification after refresh

From the skill root:

```bash
find references/upstream/agentskills -type f | sort
rg -n "docs/vendor|/home/exedev|\.pi/skills" SKILL.md references scripts assets || true
```

If this skill lives inside the full `lefant/agent-skills` repo, also run from the repo root:

```bash
./scripts/check-vendor-layout.sh
```

## Anthropic `skill-creator`

This skill may compare itself against the upstream Anthropic `skill-creator` if that package is available in a host repo, but it must not depend on it.

In `lefant/agent-skills`, Anthropic `skill-creator` is vendored separately as an installable skill at:

- `vendor/anthropics/skill-creator/`

Do not copy that package into this skill unless a concrete workflow needs specific files from it. Keep this skill self-contained by distilling required guidance into `SKILL.md`, `references/`, `scripts/`, or `assets/`.
