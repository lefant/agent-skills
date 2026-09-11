# Agentic project guide

Use this guide when preparing a repository for coding agents or reviewing an
existing setup. The goal is a fresh checkout that a human or agent can understand,
change, and verify without previous chat context.

Start with [documentation and learning](documentation-and-learning.md): the
documentation map, ADR and devlog templates, and the research → implement → review
→ compound loop that makes verified lessons available to future sessions.

This directory is a self-contained adoption guide, not an installed skill or
scaffold. An agent can apply it to another repository without reading this source
repository's root README, agent instructions, or skill packages. Commands and paths
below are examples, not implementations supplied by this guide.

## Copy-and-paste adoption prompt

Give this prompt to an agent running in the repository you want to improve:

```text
Read https://github.com/lefant/agent-skills/blob/main/docs/reference/agentic-project-guide/README.md
and all companion Markdown files in that directory. Clone the source repository
into a separate reference checkout if needed.

Then adopt the guide in the current repository you are working in, not the source
checkout. Implement the changes rather than only reporting recommendations.
In particular, add or reconcile the root README.md's Documentation & Process
section and make root AGENTS.md and CLAUDE.md reference it. Preserve existing
instructions and work, adapt the templates to this project's actual tools and
docs, and verify the resulting links and supported commands.

The guide directory is sufficient; skills and plugins it names are optional.
Check which recommended skills are available and recommend installing missing
documentation skills from lefant/agent-skills, plus the Compound Engineering
plugin or an equivalent skill bundle. Ask before installing skills or plugins.
Do not publish changes or mutate shared services without the required
authorization. Report what you adopted, what does not apply, and any blocked
verification.
```

## Instructions for the adopting agent

The **destination** is the repository where the user asked you to work. Keep any
reference clone separate; do not mistake adopting this guide for editing
`lefant/agent-skills`. Read these four files from the same source revision:

| File | Use |
|---|---|
| `README.md` | Adoption instructions and completion checks |
| [documentation-and-learning.md](documentation-and-learning.md) | Copyable root README section, agent-entry-point pointer, document templates, and learning workflow |
| [testing.md](testing.md) | Risk-based verification and safe test data |
| [development-and-delivery.md](development-and-delivery.md) | Reproducible development, continuous checkpoints, and delivery boundaries |

**The required adoption result is in the destination's root files.** Add or merge
the `Documentation & Process` section from the documentation guide into root
`README.md`. Create root `AGENTS.md` and `CLAUDE.md` if absent; otherwise merge
their pointers without replacing existing rules or imports. Both must link to
`README.md#documentation--process` (or the actual heading anchor if adapted).
Keep the detailed policy in the README instead of maintaining three copies.

Use the documented `docs/` layout for new work, reconciling existing document
owners rather than creating competing homes or moving historical files. Name
optional areas as optional; do not create empty folders or claim missing commands
and tools exist. Apply relevant testing and development improvements at the scale
of the project, without turning adoption into an unrelated infrastructure rewrite.

All required templates and workflow guidance are bundled here. Installed skills
can help, but their absence must not block adoption. Use the bundled instructions
directly and omit unavailable skill links or mark them as optional. Never copy
`lefant/…` links from the source repo into a destination where they do not resolve.

Copying this guide directory into the destination is optional, not the outcome.
If retained, copy it intact and link to its local entry point. If not retained,
write enough policy into the destination README that future sessions do not depend
on a temporary checkout or this conversation.

## Recommend supporting skills and workflows

Check the destination agent's available skills before recommending additions.
Recommend these missing skills from [lefant/agent-skills](https://github.com/lefant/agent-skills):

| Skill | Purpose |
|---|---|
| `feature-specs` | Living feature requirements: WHAT and WHY |
| `architecture-decision-records` | Architectural choices and their rationale |
| `changelog-fragments` | Release notes for meaningful completed changes |
| `devlog` | Session outcomes, evidence, caveats, and follow-ups |
| `atomically-land` | Close out work and reconcile plans, specs, decisions, and logs |

Also recommend the [Compound Engineering plugin](https://github.com/EveryInc/compound-engineering-plugin)
or an equivalent skill bundle compatible with the destination agent for the
Research/Plan → Implement → Review → Compound workflow. Prefer an existing
equivalent over installing duplicate workflows. This is a separate distribution,
not part of the documentation skills listed above.

Explain what is missing and why it helps, then obtain approval before installation.
Confirm the target agent and project-local versus user-wide scope; use its current
supported installation mechanism and the source's current instructions. Do not
install the entire skills collection when only these skills are needed. Verify
discoverability after an approved installation before documenting invocation names.

If installation is declined, unavailable, or awaiting approval, continue adoption
using this guide's bundled instructions. Report recommended-but-not-installed tools
separately from available ones. Installing tools is recommended, not a prerequisite
for setting up the destination's documentation and agent entry points.

## Start with the smallest useful setup

1. Read the destination README and applicable agent guidance. Inspect source
   ownership, commands, tests, CI, deployment triggers, and uncommitted work.
2. Record what already works, what is missing, and which gaps affect the requested
   work. Recommend missing supporting skills and workflows as described above.
   Preserve existing conventions and unrelated changes.
3. Establish the [documentation and learning workflow](documentation-and-learning.md),
   including the three root entry points above, using existing document owners
   and creating only documents with content to own.
4. Make installation and the cheapest meaningful checks reproducible. Document
   prerequisites and distinguish local commands from shared-state mutations.
5. Add coverage for the actual risks using [testing and evidence](testing.md).
   Browser coverage is relevant to web UIs, not a requirement for every repository.
6. Use [development and delivery](development-and-delivery.md) for applications,
   remote previews, or releases when those capabilities apply.
7. Exercise the supported commands from a clean checkout when practical. Report
   exact commands, results, missing coverage, and any cleanup still required.

A small library may need only a README, concise agent guidance, locked setup,
and focused tests. A deployed application may also need isolated integration
tests, browser journeys, operational runbooks, and release checks. Add documents
and automation when they own useful content, not to fill a template tree.

## Verify adoption before finishing

- The destination root README contains the documentation map, skill availability,
  `docs/` output paths, and Research/Plan → Implement → Review → Compound workflow,
  with devlogs for session evidence and solutions for reusable lessons.
- Both root agent entry points link to that section. Existing imports and rules
  still work, and no reference-checkout paths or broken skill links remain.
- Missing supporting skills and workflows have been recommended; distinguish
  available, installed with approval, and deferred tools in the adoption report.
- README commands match the destination's tooling. Run applicable safe checks and
  report decisive results; distinguish unavailable verification from success.
- Continuous pushes remain conditional on authorization, and test guidance prefers
  isolated environments without introducing shared-environment coordination.
- Review the diff for unrelated changes, copied project identifiers, secrets,
  empty scaffolding, and unsupported claims. Report adopted changes, omissions,
  blockers, and anything still requiring approval.

## Make entry points accurate and short

The root README should explain purpose, repository layout, source/generated
boundaries, setup, configuration prerequisites without secrets, and canonical
development/check/build/test commands. Link to detailed runbooks and a
documentation map instead of repeating them. Include architecture and preview
instructions where they help a new contributor.

Repository agent guidance should contain local facts and rules that an agent
cannot reliably infer: where to start, which commands are supported, which files
are generated, important contracts, and approval boundaries. Put directory rules
near their owners and keep tool-specific entry points aligned with one policy.
Do not repeat an entire agent's generic operating instructions.

Prefer one supported command interface that local development and CI both use.
Pin tool versions where reproducibility requires it; commit lockfiles and use
locked installation where the ecosystem supports them. Independent projects do
not need a forced shared dependency graph. Never advertise a command as working
until it has been exercised; label proposed or blocked commands explicitly.

## How the recommendations were reviewed

This guide is a generalized synthesis, not evidence of a destination repository's
current defects or an audit certification. It includes no source-project incident
records, links, identities, paths, data, or deployment configuration.

- **Retained:** executable setup, clear documentation ownership, behavior-focused
  tests, honest evidence, privacy controls, explicit shared-state authority, and
  continuous pushes of coherent, checked checkpoints once authorized.
- **Made conditional:** browser testing, service supervision, extensive document
  metadata, and release orchestration.
- **Not adopted as defaults:** duplicated application clients for tests,
  production-derived fixtures, mandatory feature branches, prescribed maintenance
  cadence, or a particular plugin.
- **Kept outside this guide:** platform configuration snippets and installation
  instructions that should be checked against current tool documentation.

Keep this as docs while it serves as a reference. A future `project-onboarding`
skill should have a bounded task: assess a repository, agree the relevant gaps,
apply a minimal setup, and verify it. It should bundle its required references,
reuse existing documentation skills, and never imply permission to install tools,
publish changes, or mutate shared services.
