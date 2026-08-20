# Publishing This Library to Amp Skills

This recipe tells Amp how to publish the curated skills in this repository to an Amp Personal Skills or Workspace Skills repository. Use the same procedure for the initial publication and every later synchronization.

The Amp-hosted skills repository is the durable destination. Skills published there are available in new Amp threads across projects and in orbs. Installing into `~/.config/agents/skills/` with `amp skill add --global` is machine-local and is not a substitute for publishing when orb persistence is required.

## Source and destination layouts

This repository remains the source of truth and keeps its provenance-oriented layout:

```text
lefant/<skill>/SKILL.md
vendor/<source>/<skill>/SKILL.md
```

An Amp Personal or Workspace Skills repository requires every skill at its top level:

```text
<skill>/SKILL.md
<skill>/scripts/...
<skill>/references/...
```

Flatten only the source and vendor containers. Copy each complete skill directory so its scripts, references, templates, executable bits, and other resources remain intact. Do not flatten files inside a skill.

The only current packaging exception is documented under “Known packaging override” below. Do not introduce another transformed copy merely to work around a failed publication: first verify which skill is missing, preserve all substantive content, and record the transformation in the destination manifest.

## Scope selection

1. Run `amp skills repositories --json` to discover the available repositories, clone URLs, and write permissions.
2. Use the Personal Skills repository by default.
3. Use a Workspace Skills repository only when the user explicitly requests workspace publication and the discovered repository is writable. Publishing there affects every workspace member and normally requires workspace-admin permission.
4. Do not silently fall back from the requested scope to another scope.

Use the canonical clone directory under `~/.cache/amp/repositories/`, as prescribed by Amp's `building-skills` workflow. Reuse that checkout when it exists. If it contains uncommitted changes, stop and reconcile them instead of discarding or overwriting them.

For an existing clean checkout, fetch and update it to the remote `main` before editing. Otherwise, clone it using the command reported by `amp skills repositories`, for example:

```bash
amp clone user-skills <canonical-clone-directory>
```

An empty scope is valid: Amp creates its repository on the first push. If there is not yet a remote repository to clone, initialize the canonical directory, configure Amp's Git credential helper, commit the generated content, and add the clone URL reported by `amp skills repositories` as `origin` before the first push.

## Build the source inventory

Publish only committed skill directories at these exact depths:

```text
lefant/*/SKILL.md
vendor/*/*/SKILL.md
```

Before copying anything:

1. Read `README.md` and run `./scripts/check-vendor-layout.sh`.
2. Require each skill directory's basename to equal the `name` in its `SKILL.md` frontmatter.
3. Require a non-empty frontmatter `description`.
4. Inventory names across both `lefant/` and `vendor/`, not only within each tree.
5. Resolve the known `tasknotes` collision in favor of `lefant/tasknotes`; do not publish `vendor/ArtemXTech/tasknotes` under another implicit name.
6. For any other duplicate name, stop and ask for a decision. Do not silently choose one or rename a vendored skill.
7. Exclude an entire skill containing binary files. Amp's global repositories serve text resources only, and a skill containing a binary resource will not load. Do not publish an incomplete copy with the binary silently removed; report the excluded skill and files instead. At the time this recipe was written, `vendor/remotion-dev/remotion-best-practices` is excluded because it bundles PNG icons.
8. Review bundled scripts and any `mcpServers` frontmatter or `mcp.json` as executable code. Preserve explicit MCP `includeTools` filters and stop for review if an MCP server exposes an unfiltered tool set.

Build from a clean, committed source revision so the publication is reproducible. Record `git rev-parse HEAD` as the source revision. Do not accidentally publish untracked files, local credentials, generated output, or ignored files.

### Personal repository capacity

As observed on 2026-08-20, Amp materialized exactly the first 50 alphabetically sorted skills from a Personal Skills repository containing 70 valid text-only skills. The reload and `amp skill list --json` both reported no errors, so the repository push alone was not sufficient evidence that all 70 skills were available. The current Amp manual does not document this limit.

Until Amp documents or changes this behavior:

1. Publish at most 50 skills to one Personal or Workspace Skills scope.
2. If the selected inventory exceeds 50, stop and ask the user to choose a subset. Do not let alphabetical ordering silently choose it.
3. Prefer in-house `lefant/` skills when proposing a subset, but do not discard vendored skills without user approval.
4. A separately available Workspace Skills repository may hold another explicitly selected set, subject to workspace permission and precedence rules. Do not use workspace publication without explicit approval.

### Known packaging override

Amp did not materialize `vercel-react-best-practices` when its upstream package contained 76 text files, even with only 47 skills in the Personal Skills repository. Amp reported no reload error. The package includes both 70 source rule files and a generated `AGENTS.md` containing all 70 compiled rules.

For the Personal Skills destination:

1. Copy `SKILL.md`.
2. Copy the upstream compiled `AGENTS.md` to `references/rules.md`.
3. Change the resource paths in the copied `SKILL.md` to point to `references/rules.md`.
4. Omit the redundant `rules/`, `README.md`, and `metadata.json` from the destination copy.
5. Verify that all 70 upstream rule titles occur in `references/rules.md`.
6. Record the transformation under `packagingOverrides` in the destination manifest.

This produces two text files totaling approximately 116 KB while preserving the complete compiled guidance. Keep the unmodified upstream package in this source repository.

### Current Personal Skills profile

The user selected an in-house-first Personal Skills profile: publish all skills under `lefant/` plus these 24 vendored skills:

```text
agent-browser
ai-sdk
ast-grep
chrome-devtools-cli
context7
defuddle
devenv
frontend-design
get-api-docs
json-canvas
librarian
marimo-notebook
marimo-pair
markdown-converter
pdf
provider-upgrade
pulumi-best-practices
pulumi-overview
pulumi-terraform-to-pulumi
show-me
skill-creator
ste-writing
vercel-react-best-practices
zfc
```

Apply this profile on later Personal Skills synchronizations unless the user asks to change it. Record every valid but unselected skill in `excludedSkills` with the reason `Not selected for the Personal Skills profile.` This makes profile exclusions visible without granting sync ownership over a destination directory that is not present. The profile intentionally leaves three of the observed 50 slots unused rather than adding unrequested skills.

## Track sync ownership

Maintain this text file in the destination repository:

```text
.lefant-agent-skills-sync.json
```

It should contain at least:

```json
{
  "source": "https://github.com/lefant/agent-skills",
  "sourceRevision": "<full Git commit SHA>",
  "skills": ["<sorted skill names managed by this sync>"],
  "excludedSkills": {
    "<skill name>": "<reason it could not be published>"
  },
  "packagingOverrides": {
    "<skill name>": "<destination transformation and reason>"
  }
}
```

This manifest defines which destination directories this recipe owns. It prevents later synchronization from deleting unrelated skills that were created directly in the Personal or Workspace Skills repository.

### Initial publication

If the manifest does not exist:

1. Treat no existing destination skill as owned by this source repository.
2. If a source skill name already exists at the destination, compare it and ask before adopting or replacing it.
3. Copy the complete selected source skill directories to top-level destination directories.
4. Write the manifest with the source revision and sorted published names.

### Later synchronization

If the manifest exists:

1. Validate that its `source` identifies this repository.
2. Read the previous managed-name set from the manifest.
3. Replace each currently selected, previously managed skill with an exact copy from the source revision.
4. Add newly selected names. If a new name collides with a destination directory not listed in the previous manifest, stop and ask before replacing it.
5. Delete a destination skill only when its name was listed in the previous manifest and it no longer exists in the selected source inventory.
6. Preserve every destination file and skill not owned by the previous manifest.
7. Apply and validate documented packaging overrides after copying their source directories.
8. Rewrite the manifest with the new source revision, sorted selected names, current exclusions, and packaging overrides. An exclusion is informational and does not grant ownership of an existing destination directory with that name.

Perform the copy through a temporary staging directory, then apply it to the destination checkout. This makes it possible to validate the complete flattened tree before changing the checkout and ensures removed files inside an updated skill do not linger.

## Review and publish

In the destination checkout:

1. Confirm every managed directory has `SKILL.md` directly inside it.
2. Recheck that every directory name matches its frontmatter `name` and that managed names are unique.
3. Confirm the destination contains no binary files within managed skills.
4. Inspect `git status --short` and `git diff --stat`, then review the substantive diff. Pay particular attention to scripts, MCP configuration, new skills, and deleted skills.
5. Run `git diff --check`, but distinguish generated-file defects from whitespace already present in exact vendored copies. Generated files must pass. Report upstream whitespace without normalizing curated content only to make the check green.
6. If there is no diff, report that the destination is already synchronized. Do not create an empty commit or push.
7. Commit the destination change with a message that includes the abbreviated source revision, for example `Sync lefant agent skills from abc1234`.
8. Do **not** push until the user explicitly approves publishing to the named Personal or Workspace Skills repository. A commit in the local clone does not make the skills available to Amp.
9. After approval, push the destination repository's `main` branch.

Do not commit generated destination files back into this source repository, and do not push changes to this source repository as part of the publishing operation.

## Verify availability

After a successful push:

1. Use Amp's `reload_skills` tool in the current thread. Running `amp skills list` in a shell does not reload an already-running agent session.
2. Run `amp skill list --json` and compare the names reported with source `global-user` or `global-workspace` against every name in the destination manifest. Treat missing names as a failed or partial publication even when Amp reports no explicit errors.
3. Inspect the available skills and their origins. New threads load the published skills automatically.
4. If a published skill is not selected, check repository capacity and Amp's precedence rules. A local skill with the same name masks a Personal or Workspace skill, and a Personal skill masks a Workspace skill for that user.
5. Report the destination scope, source revision, added/updated/deleted/excluded/missing skill names, validation result, and whether the current thread was reloaded.

Publication distributes skill instructions and bundled text resources, not credentials or system dependencies. Skills that require API keys, CLIs, language packages, or services must still find those prerequisites in the target project, runner, or orb environment.

## Prompt recipe

From a clean checkout of this repository, the user can ask Amp:

> Synchronize this repository's curated skills to my Amp Personal Skills repository using `docs/reference/amp-skill-publishing.md`. Prepare and validate the destination commit, report the diff, and ask before pushing it.

For workspace-wide publication, replace “Personal Skills” with “Workspace Skills.”

## References

- [Amp Owner's Manual: Agent Skills](https://ampcode.com/manual#agent-skills)
- `README.md`
- `scripts/check-vendor-layout.sh`
- `docs/solutions/workflow-issues/vendor-skill-layout-discoverability-2026-04-29.md`
