# Adopt Documentation & Process

Copy and paste this into an agent running in the target repository:

```text
Read https://github.com/lefant/agent-skills/blob/main/docs/reference/adopt-documentation-process.md
(clone the source repo separately if needed), then apply its instructions to the
current repository. Update README.md, AGENTS.md, and CLAUDE.md; preserve existing
content and adapt the documentation paths and skill references to this project.
```

## Instructions

1. Read the target repository's root README and agent guidance. Add or reconcile
   the README section below, preserving existing conventions and unrelated work.
   This task is documentation only: do not create empty directories, move historical
   files, or change application code, tests, CI, or infrastructure.
2. Check available skills. Recommend missing `feature-specs`,
   `architecture-decision-records`, `changelog-fragments`, `devlog`, and
   `atomically-land` from https://github.com/lefant/agent-skills, plus the Compound
   Engineering plugin from https://github.com/EveryInc/compound-engineering-plugin
   or an equivalent skill bundle. Ask before installing; proceed without them if
   unavailable. Link only to real skill locations and use verified invocation names.
3. Create or update root `AGENTS.md` and `CLAUDE.md` with the pointer below.
   Preserve existing instructions and imports; keep the policy in the README.
4. Check the diff and Markdown links/anchors. Report changes and recommended tools.
   Do not push or open a PR unless authorized. No companion guide is required.

## README section to adapt

```markdown
## Documentation & Process

### Documentation (`./docs`)

Create documentation as needed; not every project needs every area.

- **`docs/specs/`**: Feature Specifications — living documents describing WHAT features do and WHY. Skill: `feature-specs`.
- **`docs/decisions/`**: Architecture Decision Records (ADRs) — immutable records of architectural choices once accepted; supersede rather than rewrite. Skill: `architecture-decision-records`.
- **`docs/changelog/`**: Release notes and changelog fragments. Skill: `changelog-fragments`.
- **`docs/solutions/`**: Documented solutions to past problems and team learnings, organized by category with YAML frontmatter (`module`, `tags`, `problem_type`).
- **`docs/reference/`**: Technical references and operational details.
- **`docs/api/`**: Technical references for internal APIs.
- **`docs/brand-guide.md`**: Brand and design guide.
- **`docs/research/`**: Discovery notes and analysis.
- **`docs/plans/`**: Implementation plans.
- **`docs/devlog/`**: Implementation outcomes, evidence, caveats, and follow-ups. Skill: `devlog`.

### AI-Assisted Development

**Workflow**: Research/Plan → Implement → Review → Compound

1. **Research/Plan** — understand current behavior and requirements, then plan changes and verification. Outputs: `docs/research/` and `docs/plans/`.
2. **Implement** — make changes and verify them against the plan.
3. **Review** — inspect correctness and coverage, resolve findings, and rerun checks.
4. **Compound** — capture verified reusable lessons in `docs/solutions/`; update existing knowledge rather than duplicating it.

Prefer Compound Engineering skills or an equivalent workflow bundle when available.
Use their verified names and output paths; do not duplicate a unified brainstorm/plan.
Record session outcomes with `devlog` in `docs/devlog/`; use `atomically-land` for closeout when available.
Recommend missing skills rather than treating them as installed or required.

Use `docs/` for new work rather than legacy `thoughts/shared/` paths in templates.
Commit small, reviewable checkpoints continuously; push checked checkpoints once
authorized for the agreed remote and branch. Check automatic deployment effects first.
```

## Pointer for both AGENTS.md and CLAUDE.md

```markdown
Follow [Documentation & Process](README.md#documentation--process) for documentation
ownership, the development workflow, and current `docs/` output paths. These paths
take precedence over legacy `thoughts/shared/` paths in skill templates for new work.
```
