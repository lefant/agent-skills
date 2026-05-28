#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

require_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

require_exec() {
  [ -x "$1" ] || fail "missing executable bit: $1"
}

require_file SKILL.md
require_file README.md
require_exec scripts/hitl-browser-hub
require_exec scripts/browser-debug-hub/bin/browser-debug-hub
require_exec scripts/browser-debug-hub/tests/smoke-app.test.sh
require_exec scripts/browser-debug-hub/tests/launcher-safety.test.sh
require_exec scripts/browser-debug-hub/tests/cdp-recorder-smoke.test.sh

for path in \
  references/prerequisites.md \
  references/demonstration-handoff.md \
  references/verification-handoff.md \
  references/credential-handoff.md \
  references/vnc-client.md \
  references/trace-artifacts-and-privacy.md \
  references/real-app-validation.md \
  references/objective-demo.md \
  evals/evals.json \
  evals/trigger-evals.json; do
  require_file "$path"
done

if ! grep -q '^name: hitl-browser-automation$' SKILL.md; then
  fail "SKILL.md frontmatter name is missing or wrong"
fi
if ! grep -q '^description: ' SKILL.md; then
  fail "SKILL.md frontmatter description is missing"
fi

# Check that markdown references named in SKILL.md exist.
while IFS= read -r ref; do
  [ -f "$ref" ] || fail "SKILL.md references missing file: $ref"
done < <(grep -oE 'references/[A-Za-z0-9_.-]+\.md' SKILL.md | sort -u)

# Avoid source-machine paths and old absolute path leakage in package docs.
if grep -RInE '/home/exedev|/Users/|/nix/store/.*/pi-coding-agent' SKILL.md README.md references evals 2>/dev/null; then
  fail "package contains absolute/source-machine path leakage"
fi

# Old top-level experiment path is allowed only as bundled runtime path.
if grep -RIn 'just browser-debug-hub\|\.\./\.\./browser-debug-hub\|docs/brainstorms/' SKILL.md README.md references evals 2>/dev/null; then
  fail "package docs reference source-repo-only paths or just aliases"
fi

if [ "$failures" -ne 0 ]; then
  echo "Package validation failed with $failures issue(s)." >&2
  exit 1
fi

echo "Package validation passed: $ROOT"
