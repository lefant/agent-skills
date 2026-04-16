---
name: skills-best-practices
description: Use when creating, extracting, reviewing, or refactoring agent skills. Covers self-contained skill packaging, SKILL.md structure, trigger descriptions, progressive disclosure, gotchas, defaults, bundled scripts, eval design, and with-skill vs baseline iteration. Use this whenever the user asks to turn docs or a workflow into a skill, improve a SKILL.md, audit skill quality, or make a skill pack more self-contained.
---

# Skills Best Practices

Use this skill when authoring or upgrading agent skills.

The target is not a pretty `SKILL.md`. The target is a skill that:

- captures real task knowledge instead of generic LLM prose
- stays self-contained and portable
- triggers on the right user intents
- gives a clear default path with explicit boundaries
- can be tested against realistic prompts

## Default workflow

1. Capture real source material first.
2. Define the skill boundary and adjacent skills.
3. Package the skill so everything it needs lives inside the skill directory.
4. Write a strong description that says both what the skill does and when to use it.
5. Keep `SKILL.md` lean; move detail into `references/`, `scripts/`, and `assets/`.
6. Add defaults, gotchas, validation steps, and output expectations.
7. Create a small eval set, compare with-skill vs baseline, and iterate.

## Non-negotiables

- Do not synthesize the skill from generic best-practices alone. Mine real runs, docs, fixes, traces, specs, and corrections.
- Keep the package self-contained. If the skill needs guidance, templates, schemas, or helper scripts, vendor or rewrite them inside this skill instead of pointing at repo-external docs.
- Use relative paths from the skill root for bundled files.
- Keep `SKILL.md` focused on the workflow the agent needs on nearly every invocation.
- Put trigger guidance in the frontmatter `description`, not hidden in the body.
- Prefer one clear default path over a menu of equal options.
- Add verification steps for anything easy to fake, skip, or get subtly wrong.

## Read only what you need

- `references/authoring-guide.md` — core drafting and refactoring guidance
- `references/spec-quick-reference.md` — format, frontmatter, layout, and path rules
- `references/evals-and-iterations.md` — output-quality eval loop, assertions, grading, and iteration
- `references/description-optimization.md` — trigger evals and description tuning
- `references/scripts.md` — bundling helper scripts and designing script interfaces
- `assets/skill-template.md` — starter skeleton for a new skill
- `assets/evals-template.json` — starter output-quality eval file
- `assets/trigger-evals-template.json` — starter trigger eval file

## Self-contained packaging rule

If you are extracting a skill from repo docs, conversations, or a previous skill, copy or rewrite the necessary knowledge into this skill's own files.

Do not leave the finished skill dependent on:

- repo-specific docs outside the skill directory
- absolute paths to authoring references
- hidden tribal knowledge that only existed in the extraction session

The finished skill may still operate on user files or project files. The rule is that the skill's *instructions and bundled resources* should live inside the skill.

## Authoring loop

### 1. Capture intent from real material

Extract from real successful work:

- steps that actually worked
- corrections made during the run
- environment quirks and gotchas
- input/output formats
- validation steps
- reusable helper commands or scripts

Prefer source material in this order:

1. successful task transcripts
2. project docs, runbooks, specs, schemas
3. bug fixes, reviews, and incident notes
4. existing skill files that already work
5. generic guidance only as a final shaping pass

### 2. Define the boundary

A good skill is one coherent unit of work.

Ask:

- what job should this skill own end to end?
- what nearby jobs should stay out of scope?
- what should trigger this skill instead of a neighboring one?
- what sub-variants belong in `references/` instead of the main body?

### 3. Build the package

Use this layout:

```text
skills-best-practices/
├── SKILL.md
├── references/
├── scripts/
└── assets/
```

Put content where it belongs:

- `SKILL.md` — default workflow, boundaries, core gotchas, output expectations
- `references/` — detailed docs read only when needed
- `scripts/` — deterministic or repeated logic
- `assets/` — templates, fixtures, examples

### 4. Write the description correctly

The description is the trigger surface.

It must say:

- what the skill does
- when to use it
- user-intent phrasing, not internal implementation wording
- near-obvious trigger cases, even if the user never names the domain directly

Be slightly pushy. Under-triggering is usually worse than a carefully scoped description that is explicit.

### 5. Keep the body lean

Use progressive disclosure.

Keep `SKILL.md` limited to what the model needs on almost every run. Move long explanations, variants, API tables, and edge-case catalogs into referenced files.

When pointing to a reference, say when to read it.

Good:

- read `references/description-optimization.md` when tuning trigger coverage
- read `references/scripts.md` before bundling helper scripts

Bad:

- see `references/` for more

### 6. Prefer defaults over menus

Choose a default tool or path.

Only mention alternatives as fallbacks, and say when to switch.

### 7. Add gotchas and verification

High-value skill content is usually:

- naming mismatches
- hidden filters
- surprising API semantics
- environment or auth quirks
- dangerous paths that require a validation loop

For multi-step or destructive work, require:

- a checklist
- a plan-validate-execute flow
- or a concrete verification step before finishing

## Final review checklist

Before calling the skill done, verify all of this:

- directory name matches `name`
- description says what + when, not just what
- `SKILL.md` is the shortest version that still preserves the default workflow
- detailed or variant-specific material moved to `references/`
- repeated deterministic logic moved to `scripts/`
- output templates or fixtures live in `assets/`
- major gotchas are explicit
- default path and fallback branches are clear
- validation or verification steps exist where needed
- at least 2-3 realistic eval prompts exist for output quality
- a separate trigger eval set exists if description quality matters

## Exit standard

A good result is a skill package another agent can pick up cold, without needing the original repo docs or the original conversation, and still do the job correctly.