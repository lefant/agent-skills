# Bundling Scripts

## When to add a script

Add a bundled script when the agent keeps recreating the same deterministic logic, such as:

- validation
- parsing a known format
- exporting a report
- comparing outputs
- transforming data into a fixed intermediate form

Do not add a script just to wrap a trivial one-line command.

## What belongs in `scripts/`

Good candidates:

- validators
- format converters
- reproducible extraction helpers
- graders for eval assertions
- reusable API or schema helpers

## Script design rules

### Non-interactive only

Scripts must not depend on TTY prompts or interactive input.

Accept input through:

- command-line flags
- environment variables
- stdin

### Good `--help`

The help output should make the interface obvious.

Include:

- purpose
- required flags
- optional flags
- examples

### Useful errors

Error messages should say:

- what failed
- what was expected
- what the caller should try next

### Structured output

Prefer JSON, CSV, or other structured output when downstream automation may consume it.

Keep:

- machine-readable data on stdout
- progress logs and diagnostics on stderr

### Safe behavior

For risky operations, consider:

- `--dry-run`
- explicit confirmation flags
- idempotent behavior where possible

## Dependency strategy

If the language supports self-contained dependency declarations, prefer them.

Examples:

- Python scripts with inline metadata
- Deno scripts with versioned imports
- Bun scripts with versioned imports

If the environment requirements matter, document them in the skill.

## Referencing scripts from `SKILL.md`

Use relative paths from the skill root.

Example:

```bash
python3 scripts/<validator>.py output.json
```

Tell the agent when to run the script and why.

Good:

- run `scripts/<validator>.py` after generating the mapping to catch missing required fields before execution

Bad:

- there is a validator in scripts if needed

## Extraction heuristic

During eval review, look for repeated work across transcripts.

If multiple runs independently build nearly the same helper, bundle that helper and update the skill to use it by default.

## Keep scripts narrow

A script should solve one reusable subproblem well.

Do not replace the whole skill with one giant opaque script unless the task is almost entirely deterministic.