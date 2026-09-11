# Documentation, decisions, devlogs, and compound learning

This workflow is the foundation of the project guide: preserve requirements,
decisions, evidence, and verified lessons so each session can build on previous
work. Use existing repository conventions; create documents when they have content
to own, not an empty tree of templates.

## Put Documentation & Process in the root README

Make the documentation map and workflow visible in the repository's top-level
README, not only in a nested guide. Adapt this section, linking skill names to
their actual installed locations where useful. Do not copy another repository's
plugin paths or invent creation commands. The `feature-specs`,
`architecture-decision-records`, and `changelog-fragments` skills replace the old
`spec_create`, `adr_create`, and `changelog_create` commands.

Skill names in the template are optional aids, not prerequisites. If they are not
installed, recommend them using the [adoption guide](README.md#recommend-supporting-skills-and-workflows)
and obtain approval before installation. Until available, omit the skill bullets
or label them as recommended; use this document's workflow and templates directly.
A feature spec needs purpose, requirements,
observable acceptance scenarios, and open questions. A changelog fragment needs
the date, change type, user-facing impact, and relevant document links. The ADR,
devlog, and reusable-solution guidance appears below. No source-repository skill
files are required to establish these conventions.

```markdown
## Documentation & Process

### Documentation (`./docs`)

Create these areas when needed; not every project needs every document.

- **`docs/specs/`**: Feature Specifications — living documents describing WHAT features do and WHY
  - Skill: `feature-specs`
- **`docs/decisions/`**: Architecture Decision Records (ADRs) — immutable records of architectural choices once accepted
  - Skill: `architecture-decision-records`
- **`docs/changelog/`**: Release notes and changelog fragments
  - Skill: `changelog-fragments`
- **`docs/solutions/`**: Documented solutions to past problems and team learnings, organized by category with YAML frontmatter (`module`, `tags`, `problem_type`)
- **`docs/reference/`**: Technical references and operational details
- **`docs/api/`**: Technical references for internal APIs
- **`docs/brand-guide.md`**: Brand and design guide
- **`docs/research/`**: Discovery notes and analysis
- **`docs/plans/`**: Time-stamped implementation plans
- **`docs/devlog/`**: Time-stamped implementation outcomes and learnings
  - Skill: `devlog`

### AI-Assisted Development (`./docs`)

**Workflow**: Research/Plan → Implement → Review → Compound

Prefer Compound Engineering skills when installed; verify that version's names
and output paths. If missing, recommend the plugin or an equivalent skill bundle,
along with missing documentation skills from lefant/agent-skills. Install only
with approval; the workflow remains usable without these tools.

1. **Research/Plan** — document current behavior and requirements, then define
   implementation and verification. Outputs: `docs/research/` and `docs/plans/`.
   Keep a unified brainstorm/plan artifact if the plugin uses one; do not duplicate it.
2. **Implement** — make source changes and verify the result.
3. **Review** — inspect correctness and coverage, fix findings, and rerun checks.
4. **Compound** — preserve verified reusable lessons in `docs/solutions/`.

Use `devlog` at meaningful checkpoints to record outcomes, evidence, caveats, and
follow-ups in `docs/devlog/`. Session history and reusable solutions have different owners.
Use `docs/` paths for new work even when an older template still says `thoughts/shared/`.

Commit progress continuously in small, reviewable increments. Once authorized for
the agreed remote and branch, push each coherent, checked checkpoint without asking
again. Check automatic deployment effects first; separate release actions remain gated.
```

Reference this section from both root `AGENTS.md` and root `CLAUDE.md`, preserving
any existing imports and instructions. A short pointer is sufficient:

```markdown
Follow [Documentation & Process](README.md#documentation--process) for documentation
ownership, the AI-assisted workflow, and current `docs/` output paths. These paths
take precedence over legacy `thoughts/shared/` paths in skill templates for new work.
```

Keep the policy in the README rather than duplicating the full section across
agent entry points. Verify the links and anchor after adoption. Do not move historical
files or install a plugin merely to establish this convention.

## Give each document one responsibility

Use a documentation map such as `docs/README.md` to identify these owners:

| Question | Owner |
|---|---|
| Why build this, and what matters next? | Product strategy |
| What exists and how do its parts connect? | Root README |
| What behavior is required, and why? | Living feature/layer specifications |
| Why was a consequential design chosen? | Accepted ADRs |
| How do I operate, test, or recover it? | Current runbooks/references |
| What work is active? | Active plan or issue |
| What happened in a session or incident? | Dated devlog or incident report |
| How do I apply a proven lesson? | Searchable solution document |

These are responsibilities, not a mandatory folder hierarchy or authority ranking.
Executable behavior is determined by code/configuration/workflows. If that
contradicts a spec, investigate and record the mismatch; neither silently
rewrite intent to match a bug nor treat old prose as operational authority.

Separate living docs from history. Suggested living metadata: `status`,
`owner`, and `last_verified`. Use `current`, `draft`, or `deprecated`; change
the verification date only after checking the owning source. Landing pages
can omit frontmatter. Add link/metadata checks to CI as the collection grows.

Plans should distinguish `proposed`, `active`, `blocked`, `completed`,
`abandoned`, and `superseded`. At completion, append shipped outcomes and
resolved decisions, mark remaining work explicitly, and link the current spec.
Preserve original intent rather than rewriting history to imply no deviation.

## Architecture decision records

Write an ADR for a consequential choice with plausible alternatives, lasting
constraints, security implications, or expensive reversal. Do not write one
for every helper or routine implementation detail.

Suggested filename: `YYYY-MM-DD_short-decision.md` under `docs/decisions/`.
Use the destination's existing format if it has one.

```text
Status: proposed | accepted | rejected | deprecated | superseded
Date and owner:
Context: problem, evidence, constraints, and decision drivers.
Options: credible alternatives and their relevant tradeoffs.
Decision: chosen approach and why it fits these constraints.
Consequences: costs, limitations, risks, and operational obligations.
Verification: evidence or proof supporting the choice.
Revisit when: specific conditions that could reverse the choice.
Related: spec, implementation, and replacing/amending ADR when applicable.
```

Preserve an accepted decision's original rationale. A changed decision gets a
new ADR and a supersession/amendment link; a dated clarification may explain
where the implementation now lives without pretending that was always true.

## Devlogs: evidence rather than session transcripts

Write a short dated entry at a meaningful checkpoint, handoff, or completion
of substantial work. Prefer this structure:

```text
Goal and scope: user requirement, summarized with sensitive details removed.
Outcome: what works, what remains partial, and relevant revision/environment.
Plan versus shipped result: deviations and concise decision rationale.
Verification: exact safe commands, working directory, result/exit status,
  decisive output, tested scenarios, and links to sanitized evidence.
Limitations: failures, skipped coverage, and what conclusions are unsupported.
Learning: root cause or reusable practice, linked to its durable home.
Handoff: next concrete action, owner, blockers, cleanup/release state.
```

Record decision summaries, not private reasoning traces. Do not blindly copy
prompts, environment dumps, or raw logs. Quote useful measured results rather
than saying “all good.” When piping checks to `tee`, preserve failure status
(for example with Bash `set -o pipefail`); sanitize before publishing output.

## Compound learning: make verified lessons available to the next session

Use this loop whether or not a plugin is installed:

1. **Research/plan:** read relevant solutions and specs, identify risks, define
   acceptance and test evidence, and resolve uncertain choices with a small proof.
2. **Implement:** make a bounded change and verify incrementally.
3. **Review:** inspect correctness, contracts, security, test blind spots, and
   operational effects. Apply fixes and rerun affected checks.
4. **Compound:** turn a verified, reusable lesson into a solution or update its
   existing owner. Link it from the devlog and relevant spec/runbook.

For a solution under `docs/solutions/<category>/`, record searchable metadata
such as `module`, `tags`, and `problem_type`, plus symptoms, cause, failed
approaches, the verified fix, prevention, applicability, and evidence. Search
first; extend an existing solution instead of duplicating it. A suspected fix
is not yet a proven solution.

## Compound Engineering plugin or equivalent skill bundle

Recommend the Compound Engineering plugin or an equivalent compatible skill bundle
when no suitable workflow is available. If adopting one, obtain explicit installation
approval, verify the plugin identity and installed version, and use that
version's documented commands and config schema. Map its output into the same
documentation hierarchy rather than creating another source of truth.

Keep local plugin configuration ignored, with a non-secret example if useful.
Leave delegation disabled unless requested or explicitly approved. Review
sandbox settings and permissions; do not copy unrestricted execution, blanket
auto-accept, machine-specific model choices, or analytics defaults from another
repository. Delegated work must have clear ownership and integration checks.

A configuration example is not evidence of an installed plugin or a working
workflow. Verify the setup before documenting commands as supported. The learning
loop above remains usable without the plugin.
