# lefant/agent-skills

Curated skills for AI coding agents (Claude Code, Codex, OpenCode).

## Structure

- `lefant/` - Custom skills developed in-house
- `vendor/` - Vendored skills from upstream repositories (reviewed for security)

## Reference Guides

- [Agentic project guide](docs/reference/agentic-project-guide/README.md) —
  Start with [documentation and learning](docs/reference/agentic-project-guide/documentation-and-learning.md):
  documentation ownership, ADRs, devlogs, and reusable solutions. The guide also
  covers repository onboarding, testing, and safe delivery. Read or copy it; it is
  not installed by the skills CLI.

## Documentation & Process

### Documentation (`./docs`)

Start with the [agentic project guide](docs/reference/agentic-project-guide/README.md)
and its [documentation and learning workflow](docs/reference/agentic-project-guide/documentation-and-learning.md).

Use these documentation areas. Create optional directories only when there is
content to own; not every area below exists in this tooling repository yet.

- **`docs/specs/`**: Feature Specifications — living documents describing WHAT features do and WHY
  - Skill: [`feature-specs`](lefant/feature-specs/SKILL.md)
- **`docs/decisions/`**: Architecture Decision Records (ADRs) — immutable records of architectural choices once accepted; supersede rather than rewrite their rationale
  - Skill: [`architecture-decision-records`](lefant/architecture-decision-records/SKILL.md)
- **`docs/changelog/`**: Release notes and changelog fragments
  - Skill: [`changelog-fragments`](lefant/changelog-fragments/SKILL.md)
- **`docs/solutions/`**: Documented solutions to past problems and team learnings, organized by category with YAML frontmatter (`module`, `tags`, `problem_type`)
- **`docs/reference/`**: Technical references and operational details
- **`docs/api/`**: Technical references for internal APIs, when applicable
- **`docs/brand-guide.md`**: Brand and design guide, when applicable
- **`docs/research/`**: Discovery notes and analysis
- **`docs/brainstorms/`**: Existing standalone brainstorms and design explorations
- **`docs/plans/`**: Time-stamped implementation plans
- **`docs/devlog/`**: Time-stamped implementation outcomes, caveats, and learnings
  - Skill: [`devlog`](lefant/devlog/SKILL.md)

The spec, ADR, and changelog skills replace the old `spec_create`, `adr_create`,
and `changelog_create` commands. Use the installed agent's skill invocation syntax;
the links above point to the maintained skill instructions.

### AI-Assisted Development (`./docs`)

**Workflow**: Research/Plan → Implement → Review → Compound

Prefer the Compound Engineering skills when installed. Verify the installed
version's skill names and output paths before invoking them; this repository does
not install that plugin. The workflow also works without it.

Commit progress continuously in small, reviewable increments. Once continuous
pushes to the agreed remote and branch are authorized, push each coherent, checked
checkpoint without asking again. Inspect automatic deployment effects first;
separate release and shared-state actions still need their own authorization.

1. **Research/Plan** — document current behavior, constraints, and requirements;
   define implementation strategy and verification. Durable research belongs in
   `docs/research/`, and plans in `docs/plans/`. A plugin may keep brainstorm and
   planning work in one plan artifact; do not duplicate it just to fill folders.
2. **Implement** — make the source changes and verify them against the plan.
3. **Review** — inspect correctness, contracts, security, and test coverage;
   resolve findings and rerun affected checks.
4. **Compound** — capture verified reusable solutions in `docs/solutions/` and
   update their existing owners rather than duplicating knowledge.

At meaningful checkpoints, use [`devlog`](lefant/devlog/SKILL.md) to record outcomes,
evidence, caveats, and follow-ups in `docs/devlog/`. Devlogs preserve session history;
solutions preserve reusable knowledge. Use [`atomically-land`](lefant/atomically-land/SKILL.md)
when closing out work that also needs plans, specs, ADRs, or changelog updates.

Use `docs/research/`, `docs/plans/`, and `docs/devlog/` for new work, even where an
older skill template still says `thoughts/shared/`. The [`rpi`](lefant/rpi/SKILL.md)
skill remains available for explicitly requested legacy workflows; it is not the
default process. Do not move historical files merely to follow the new convention.

## Usage

### With skills CLI
```bash
skills add /path/to/agent-skills --skill '*' -g -y -a claude-code -a codex -a opencode
```

### In Docker
Cloned to `/opt/lefant-agent-skills` and symlinked via entrypoint.

## Updating Vendored Skills

```bash
./scripts/update-vendor.sh
```
Then review changes before committing.

### Vendor Quality Checks

Before committing vendor changes, verify skill discoverability:

```bash
./scripts/check-vendor-layout.sh
```

For quick manual inspection:

```bash
find vendor -type d -name skills -print
find vendor -path '*/SKILL.md' -printf '%h\n' | sort
```

Rules:

- `find vendor -type d -name skills -print` should normally print nothing. Vendored skills must be flattened to `vendor/<source>/<skill>/SKILL.md`, even when upstream stores them under `skills/`.
- Do not vendor whole plugin bundles that need agents, commands, MCP config, or other non-skill assets unless the installer can consume those assets. Handle plugin-native bundles in a plugin/package layer instead.
- Keep source-to-local path mappings in `scripts/update-vendor.sh`; do not rely on symlinks for discoverability.
- Keep frontmatter `name:` values unique across `lefant/` and `vendor/`; installers expose one skill per name.

## Skills Included

### Custom Skills (`lefant/`)

| Skill | Description |
|-------|-------------|
| `github-access` | Access GitHub repositories via gh CLI or REST API |
| `sentry` | Fetch and analyze Sentry issues, events, and logs |
| `architecture-decision-records` | Create and manage ADRs |
| `changelog-fragments` | Maintain changelog fragments for conflict-free history |
| `feature-specs` | Document feature requirements and scenarios |
| `atomically-land` | Close out implementation work and update surrounding docs/tracking |
| `devlog` | Write implementation devlogs for current session state |
| `exa` | Use Exa for web search, code context lookup, and current-information lookups via SDK, API, or MCP |
| `skills-best-practices` | Create, review, and refactor agent skills with self-contained packaging and eval guidance |
| `github-get-pr-comments` | Gather PR comments and combine them with local project context |
| `git-resolve-merge-conflicts` | Resolve git merge conflicts safely using local context |
| `mermaid-diagrams` | Create hierarchical Mermaid diagrams |
| `handover` | Generate a concise resume prompt for the next session |
| `hitl-browser-automation` | Run human-in-the-loop browser automation with VNC, loopback CDP, smoke validation, and agent-browser continuation |
| `rpi` | Preserve the create_plan, implement_plan, and research_codebase workflows |
| `recent-context-from-git` | Summarize recent local docs and work context from git history |
| `test-analyzer` | Analyze CTRF test reports with jq |
| `youtube-transcript` | Fetch YouTube video transcripts |
| `tasknotes` | Manage Obsidian tasks through maintained TaskNotes interfaces or a safe Markdown fallback |
| `untis-access` | Access WebUntis data, compare repo implementations, and run proven message/timetable scripts |

### Vendored Skills (`vendor/`)

See `vendor/README.md` for sources and update process.
