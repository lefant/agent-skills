# Agent Skill Authoring Best Practices

This document collects the repo-level skill-authoring guidance imported from public Agent Skills documentation and reconciles it with the skills that already exist in this repository.

Use this as durable reference material. For day-to-day authoring, reviewing, or refactoring skills, prefer the operational skill at `lefant/skills-best-practices/`.

Primary sources in this repo:

- `lefant/skills-best-practices/references/upstream/agentskills/llms.txt`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/best-practices.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/evaluating-skills.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/optimizing-descriptions.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/skill-creation/using-scripts.mdx`
- `lefant/skills-best-practices/references/upstream/agentskills/docs/specification.mdx`
- `vendor/anthropics/skill-creator/SKILL.md`
- `lefant/skills-best-practices/SKILL.md`
- `lefant/skills-best-practices/references/`

## Existing Repo Context

This repo already contains two authoring-oriented skills:

- `lefant/skills-best-practices/` — the local, compact skill for creating, reviewing, and refactoring agent skills. It is the default skill to use for local authoring work.
- `vendor/anthropics/skill-creator/` — the upstream Anthropic `skill-creator` package, vendored as an installable skill with its scripts, references, assets, and agents.

The imported public docs do not replace either one. They provide a traceable reference snapshot for why the local `skills-best-practices` guidance is shaped the way it is, and for future audits of skill format, evaluation, scripting, and trigger descriptions.

Current skill roots in this repo are:

- `lefant/<skill>/` for in-house skills
- `vendor/<source>/<skill>/` for vendored upstream skills

Vendored skills must stay flattened to `vendor/<source>/<skill>/SKILL.md`; do not introduce nested `vendor/**/skills/<skill>/SKILL.md` layouts. Run `./scripts/check-vendor-layout.sh` after vendor changes.

## What To Optimize For

### 1. Start from real expertise, not generic prose

Build or improve skills from real material:

- successful task transcripts
- corrections made during those runs
- project docs, runbooks, schemas, and contracts
- bug fixes, review comments, and incident notes
- existing skills that already work

The anti-pattern is writing a skill from generic "best practices" alone. That usually creates vague advice like "handle errors appropriately" instead of the concrete defaults and gotchas that improve agent behavior.

For this repo:

- mine devlogs, plans, verification output, and actual skill changes first
- turn repeated steering into explicit skill instructions
- prefer local workflow defaults over generic platform summaries

### 2. Keep each skill a coherent unit of work

Scope a skill like a function.

Too narrow:

- multiple overlapping skills must activate for one ordinary task
- the agent bounces between tiny packages

Too broad:

- triggering becomes imprecise
- unrelated instructions load together
- `SKILL.md` becomes a grab bag

A good skill owns one cohesive job with closely related substeps. If a skill supports multiple subflows, keep the shared default in `SKILL.md` and move variants into `references/`.

### 3. Spend context carefully

Skills use a layered loading model:

1. `name` and `description` are always visible
2. `SKILL.md` loads on activation
3. `references/`, `scripts/`, and `assets/` load only when needed

Best-practice consequences:

- keep `SKILL.md` lean
- include only information the model would likely miss without help
- do not explain general concepts the model already knows
- move detailed variants and large reference material out of the main body

Useful rule of thumb:

- keep `SKILL.md` under roughly 500 lines / 5k tokens when possible
- when the skill grows, split variant-specific or rarely needed material into `references/`
- when a reference file is large, say exactly when to read it

### 4. Put trigger information in the description

The frontmatter `description` is the trigger surface.

It should say:

- what the skill does
- when to use it
- likely user-intent phrasing
- near-obvious trigger cases even when the user does not name the skill domain directly
- boundary hints when neighboring skills could be confused

Keep it concise enough to fit the 1024-character spec limit.

### 5. Prefer defaults over menus

A skill should reduce hesitation.

Instead of presenting many equal choices:

- choose the default tool, workflow, or output format
- mention alternatives only as fallbacks
- explain when to switch away from the default

### 6. Capture gotchas explicitly

High-value skill content is usually concrete and surprising:

- naming mismatches across layers
- stale or misleading top-level artifacts
- hidden filters or fallback conditions
- required env vars or path quirks
- provider-specific field semantics
- filesystem layout constraints such as this repo's flattened vendor tree

Put critical gotchas close to the main instructions.

### 7. Use `references/`, `scripts/`, and `assets/` for different jobs

Use:

- `scripts/` for deterministic or repeated logic
- `references/` for detailed docs the agent may need to read
- `assets/` for templates, fixtures, and output resources

Do not duplicate the same material in both `SKILL.md` and references. Keep navigation in `SKILL.md`; keep detail in referenced files.

### 8. Add validation loops

For multi-step, easy-to-fake, or destructive work, use structures like:

- explicit checklists
- plan-validate-execute flows
- mechanical validators
- rerun-and-fix loops

In this repo, examples include:

- `./scripts/check-vendor-layout.sh` for vendored skill layout
- metadata and frontmatter checks when adding or moving skills
- path-reference checks after flattening upstream layouts

### 9. Iterate with evals

The Agent Skills evaluation docs recommend:

- start with 2-3 realistic prompts
- run with-skill and without-skill baselines
- keep outputs per test case in a stable workspace layout
- add assertions after seeing the first outputs
- grade with evidence
- compare quality, time, and token cost
- iterate multiple times

The Anthropic `skill-creator` skill adds deeper workflows for benchmark aggregation, blind comparison, and trigger-description optimization. Use `vendor/anthropics/skill-creator/` when doing that level of evaluation.

## Specification Constraints

From `lefant/skills-best-practices/references/upstream/agentskills/docs/specification.mdx`:

- `name`
  - required
  - 1-64 chars
  - lowercase letters, numbers, hyphens
  - should match the parent directory name
- `description`
  - required
  - 1-1024 chars
  - should explain both what the skill does and when to use it
- `license`
  - optional
- `compatibility`
  - optional; use only when real environment constraints matter
- `metadata`
  - optional
- `allowed-tools`
  - optional and experimental

Recommended package shape:

```text
skill-name/
├── SKILL.md
├── scripts/
├── references/
├── assets/
└── ...
```

Repo-specific vendored package shape:

```text
vendor/<source>/<skill>/
├── SKILL.md
├── scripts/
├── references/
├── assets/
└── ...
```

## Relationship Between Authoring Skills

### `lefant/skills-best-practices/`

Use this for local skill work. It is short, self-contained, and tailored to this repo's standards:

- strong trigger descriptions
- progressive disclosure
- self-contained packaging
- concrete defaults and gotchas
- eval and validation expectations

### `vendor/anthropics/skill-creator/`

Use this as upstream reference for fuller authoring and evaluation workflows:

- user interviewing
- test-prompt generation
- with-skill vs baseline comparisons
- benchmark aggregation
- blind comparison
- description optimization

### `lefant/skills-best-practices/references/upstream/agentskills/`

Use this as public format and documentation reference:

- skill file specification
- quickstart
- creation best practices
- evaluation guidance
- script usage guidance
- client implementation notes

## Review Checklist For Skills In This Repo

1. **Description quality**
   - Does it say what the skill does?
   - Does it say when to use it?
   - Does it match user intent phrasing rather than implementation internals?
   - Does it mention near-obvious triggers, not just explicit keywords?
   - Is it under 1024 chars?

2. **Scope quality**
   - Is the skill one coherent unit of work?
   - Is it trying to cover unrelated subdomains?
   - Are neighboring skills clearly separated?

3. **Context discipline**
   - Is `SKILL.md` mostly core workflow and critical gotchas?
   - Should variant-specific details move to `references/`?
   - Is anything duplicated between body and references?

4. **Defaults and workflow clarity**
   - Is there a clear default path or tool?
   - Are fallback branches explicit?
   - Are important steps ordered clearly?

5. **Validation and output quality**
   - Does the skill require verification before finishing?
   - Is there a checklist or validation loop where needed?
   - Is the output format shown with a concrete template or example?

6. **Bundled resources**
   - Should repetitive logic become a script?
   - Should large docs move into references?
   - Are assets separated from instructions?
   - Are all bundled references relative to the skill directory?

7. **Vendor layout**
   - For vendored skills, is the path flattened to `vendor/<source>/<skill>/SKILL.md`?
   - Does `./scripts/check-vendor-layout.sh` pass?
   - Are source mappings kept in `scripts/update-vendor.sh` instead of symlinks?

8. **Evaluation readiness**
   - Are there at least 2-3 realistic eval prompts for high-value skills?
   - Is there a baseline comparison plan?
   - Are objective assertions possible for part of the task?

## Practical Starting Point For Future Cleanup

1. Audit every custom skill description in `lefant/`.
2. Check vendored layout with `./scripts/check-vendor-layout.sh`.
3. Add or tighten skill boundaries where needed.
4. Cut generic prose from `SKILL.md`.
5. Extract bulky detail into `references/`.
6. Add gotchas, defaults, and validation loops.
7. Add small eval prompt sets for high-value skills.
8. Compare revised skills against previous behavior before landing broad rewrites.

## Source Map

See also:

- `docs/reference/agent-skill-source-map.md`
- `lefant/skills-best-practices/references/upstream/agentskills/SOURCE.txt`
- `vendor/README.md`
- `scripts/update-vendor.sh`
