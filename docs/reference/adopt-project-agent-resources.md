# Adopt self-contained project agent resources

Use this guide to give a project checked-in framework documentation and a
selected set of portable skills. Another agent should be able to read the
guidance from a fresh checkout without a personal skill repository, dependency
installation, plugin runtime, or network fetch.

This is an adoption procedure, not an installer or a new skill. Reading offline
guidance does not make the application or its tools work offline. Browser
binaries, CLIs, credentials and services remain explicit runtime dependencies.

## Start with the project's stack and rules

Read the repository guidance, lockfile, deployment workflow and agent setup.
Record these inputs before choosing resources:

- Application roots, package manager, lockfile and exact resolved framework versions.
- Existing backend, authentication, storage and deployment boundaries.
- Agents that must discover the skills, and their supported project directories.
- Commands for resource refresh, resource checks and application verification.
- Source repositories, immutable revisions, selected skill paths and doc URLs.
- Local adaptations and the reasons for including or excluding each skill.

Do not inherit another application's paths, branch names, release commands,
environment names, authorship requirements or skill list. Installing guidance
does not authorize infrastructure changes or adopting the products it describes.

## Keep three resource types separate

An example project layout is:

```text
AGENTS.md                              # Small indexes and project precedence
.agents/skills/<name>/
  SKILL.md                             # One discoverable entry per skill
  SOURCE.md                            # Revision, source paths, adaptations
  LICENSE                              # Applicable upstream terms/attribution
  references/                          # Required guidance, not just URL stubs
.agents/resources/
  framework-docs/                       # Exact-version framework docs
  platform-docs/                        # Explicitly dated platform snapshots
scripts/agent-resources/
  sources.json                         # Inputs and selected source paths
  inventory.json                       # Generated output paths and hashes
  project-boundaries.md                 # Locally owned safety instructions
  refresh.*                            # Deterministic, reviewed transformations
  check.*                              # Offline structural/semantic checks
docs/reference/agent-resources.md       # Selection and maintenance runbook
```

These are example paths, not required conventions. Use the project's existing
owners and supported agent discovery directory. Keep resources inside the
checkout; avoid links into a developer's home directory or another repository.

### Framework docs must match the lockfile

Resolve the exact version from the lockfile, not a manifest range or a floating
codemod. If the installed package contains docs, first verify its version matches
the lockfile, then copy the docs and applicable license into the resource tree.
Record package name, version, resolved artifact and integrity when available.

Recent Next.js packages can provide `dist/docs`; check the actual locked artifact
before relying on that layout. For versions without bundled docs, use a verified
version-matched upstream source and record that mapping. Do not silently fall
back to current website documentation.

Generate an index from the copied files, including overview pages. Replace one
clearly marked block in `AGENTS.md`; reject missing or duplicate markers instead
of appending another block. Keep the recovery command consistent with the
documented refresh command. Check in the indexed files, not just their index.

### Platform snapshots need a separate refresh policy

Platform documentation often has no version tied to the application lockfile.
Record its canonical URL, retrieval date and content hash. Refresh those pages
only through an explicit option; an ordinary pinned rebuild should preserve the
existing snapshots. Retain attribution and check redistribution terms; public
availability alone does not grant a license to redistribute website content.
Use links instead when redistribution is not permitted, and state the resulting
network dependency rather than claiming full offline coverage.

Keep upstream-relative website links meaningful by retaining source/base URL
information or normalizing those links. Distinguish optional external reading
from instructions required to complete the skill's default workflow.

### Choose skills from source, not a marketing inventory

Inspect the pinned source's actual skills and dependencies. A product page may
describe an older inventory. Write a selection table with source path, local name,
purpose and exclusions. Choose one owner when two skills cover the same job.

For a Next.js/Vercel project, assess these groups rather than copying them all:

| Group | Candidate coverage | Selection rule |
| --- | --- | --- |
| Framework | Next.js, upgrades, cache components, bundler | Match the framework/version and actual development tasks |
| UI | React performance, shadcn, interface guidelines | Match installed UI tools; avoid duplicate rule corpora |
| Verification | Browser tooling, browser → API → data checks | Bundle the workflow and required references |
| Operations | CLI, deployment, environment variables, protected previews | Preserve the project's release and access policies |
| Optional platform features | Caching, metrics, domains, firewall, Functions | Include for an identified task; guidance does not enable the feature |
| Other products | AI SDK, auth, storage, queues, workflows | Include only when used or explicitly being evaluated |

Useful source families include `vercel/vercel-plugin`, `vercel-labs/agent-skills`,
`vercel-labs/agent-browser`, and this repository's curated `vendor/` tree. Pin each
source independently. A copied discovery stub may require guidance from a second
upstream repository; record both sources and their licenses.

## Make each selected skill portable

Copy the files needed by its default workflow, not only `SKILL.md`:

1. Preserve references, rules, templates, scripts, licenses and attribution.
   Record immutable source revisions, upstream paths and every local adaptation.
2. Retain portable skill metadata. Remove plugin-only routing, validation,
   chaining or tool restrictions that the target agent cannot interpret. Preserve
   removed metadata as provenance where useful, not as active configuration.
3. Do not install plugin hooks, agents, commands, MCP servers or telemetry merely
   by copying skills. State which runtime features are absent.
4. Repair relative links after flattening directories. Bundle required online
   rule files or CLI guide stubs when licensing allows; prefer installed CLI help
   if it differs from the bundled version.
5. Resolve cross-skill dependencies: include the dependency, replace it with
   complete local instructions, or mark a genuinely optional workflow out of
   scope. Do not remove a required dependency just to satisfy a checker.
6. Keep one discoverable `SKILL.md` and unique frontmatter name per skill. Rename
   reference-only nested entries to `guide.md` and repair their incoming links.
   Avoid duplicate discovery symlinks and check collisions with global skills.

Document the refresh transforms; do not rely on hand edits to generated output.
Make targeted text adaptations fail when their expected source text disappears,
so an upstream change cannot silently drop a safety instruction or link repair.

## Project policy takes precedence over examples

Keep a small, locally maintained boundary document. Reference it from the root
guidance and ensure it is available when a skill is loaded independently. For
portable copies, embedding it through the generator is one workable approach.
It should state:

- Existing architecture and release procedures override generic upstream examples.
- Deployment, provisioning, promotions, DNS/firewall changes and shared-data writes
  need the applicable authorization; a CLI example is not authorization.
- Do not disclose credentials in commands, logs, captures or reports, or move
  server secrets into public/client configuration. Do not blindly overwrite local
  environment files with a generic environment-pull command.
- Use the actual project's checks and trace the affected user flow end to end.
  For appearance changes, render and inspect representative affected states.
- Use available host tools; do not assume named tools or plugin hooks exist.

The generic guide must not prescribe a production branch, backend, auth model,
environment scheme or test-data policy. Those belong to each adopting project.

## Make refresh reproducible and reviewable

Keep source inputs separate from generated output hashes. Fetch immutable Git
revisions into temporary directories or read them with `git archive`; a cache is
an optimization, not a requirement. Do not execute upstream installers or hooks
as part of copying guidance. List any required local dependency-install step
separately, including its lifecycle-script implications.

Build in scratch space, validate before replacing managed output, sort indexes
and manifests, and clean up temporary files. Remove obsolete managed selections
explicitly without deleting unrelated local skills. Preserve local adaptations
in the generator or reviewed patches. Default regeneration should not update
timestamps or fetch unversioned pages. A deliberate online snapshot refresh is a
different operation and may produce a diff.

Commit indexes, copied resources, source pins, transformations and the integrity
inventory together. A content hash detects drift; it does not establish that a
source is trustworthy or that the instructions are correct.

## Verify a fresh checkout, not only the author's machine

Provide a resource checker that requires neither `node_modules` nor credentials.
It should validate:

- Exact agreement among indexed paths, copied files and the integrity inventory.
- Framework provenance/version agreement with the lockfile.
- Unique marker blocks, valid roots and complete overview-page coverage.
- Resources are tracked or eligible to be tracked, with no external symlinks.
- Expected skill names and directories, without duplicate nested entries.
- Licenses, provenance, local policy and supported frontmatter are present.
- Required local links, inline file paths and cross-skill dependencies resolve.

Run it in an isolated directory without dependencies or personal skill caches.
Test ignore rules on untracked fixture copies too: already tracked files can hide
an ignore rule that would prevent future resources from being added. Confirm
tracked completeness separately using Git's index or a committed checkout.

Add negative tests that deliberately introduce a missing indexed page, duplicate
marker, ignored resource, duplicate skill name, broken local link, unresolved
skill dependency and lockfile-version drift. When testing a semantic check,
update the fixture's checksum so a generic hash failure does not mask the bug.
Assert the intended diagnostic, not just a nonzero exit.

Run the pinned refresh twice and compare managed bytes. Reload or rescan skills
in each supported agent and confirm expected names without errors; filesystem
layout checks alone do not prove discovery. Run the project's normal applicable
checks. A documentation-only change needs no deployment, and passing packaging
checks is not evidence that cloud operations or application behavior were tested.

## Report the scope and delivery state

The adoption report should identify selections/exclusions, offline coverage,
runtime dependencies, source pins, checks actually run, and limitations. Say
whether work is local, committed, pushed, under review or merged. Do not copy
another project's test counts as an acceptance criterion.

This guide generalizes a completed project integration; it is not a tested
universal generator. It is standalone and requires no access to the source
project. Redistribution review, staged replacement and fail-fast text patches
are adoption requirements, not claims about what the original scripts verified.
