#!/usr/bin/env bash
set -euo pipefail

CHECKER="$(cd "$(dirname "$0")/.." && pwd)/check-vendor-layout.sh"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

case_number=0

new_fixture() {
    case_number=$((case_number + 1))
    FIXTURE="$TMP_ROOT/case-$case_number"
    mkdir -p "$FIXTURE/scripts" "$FIXTURE/lefant" "$FIXTURE/vendor"
    cp "$CHECKER" "$FIXTURE/scripts/check-vendor-layout.sh"
}

run_pass() {
    local label="$1"
    local output="$FIXTURE/output"

    if ! "$FIXTURE/scripts/check-vendor-layout.sh" >"$output" 2>&1; then
        echo "not ok - $label" >&2
        cat "$output" >&2
        exit 1
    fi
    echo "ok - $label"
}

run_fail() {
    local label="$1"
    local expected="$2"
    local output="$FIXTURE/output"

    if "$FIXTURE/scripts/check-vendor-layout.sh" >"$output" 2>&1; then
        echo "not ok - $label (checker unexpectedly passed)" >&2
        cat "$output" >&2
        exit 1
    fi
    if ! grep -F "$expected" "$output" >/dev/null; then
        echo "not ok - $label (missing expected error: $expected)" >&2
        cat "$output" >&2
        exit 1
    fi
    echo "ok - $label"
}

new_fixture
mkdir -p "$FIXTURE/vendor/example/inline" "$FIXTURE/vendor/example/folded" "$FIXTURE/vendor/example/literal"
cat >"$FIXTURE/vendor/example/inline/SKILL.md" <<'EOF'
---
name: inline
description: A valid inline description.
---
EOF
cat >"$FIXTURE/vendor/example/folded/SKILL.md" <<'EOF'
---
name: folded
description: >-
  A valid folded description
  on two lines.
---
EOF
cat >"$FIXTURE/vendor/example/literal/SKILL.md" <<'EOF'
---
name: literal
description: |
  A valid literal description.
---
EOF
run_pass "accepts inline, folded, and literal descriptions"

for scalar in 'description:' 'description: null' 'description: ~' 'description: # comment only' 'description: ""'; do
    new_fixture
    mkdir -p "$FIXTURE/vendor/example/invalid"
    cat >"$FIXTURE/vendor/example/invalid/SKILL.md" <<EOF
---
name: invalid
$scalar
---
EOF
    run_fail "rejects blank description scalar: $scalar" "description"
done

new_fixture
mkdir -p "$FIXTURE/vendor/example/invalid"
cat >"$FIXTURE/vendor/example/invalid/SKILL.md" <<'EOF'
---
name: invalid
description: >

---
EOF
run_fail "rejects an empty folded description" "description"

for scalar in 'description: "unterminated' "description: 'unterminated" 'description: > trailing'; do
    new_fixture
    mkdir -p "$FIXTURE/vendor/example/invalid"
    cat >"$FIXTURE/vendor/example/invalid/SKILL.md" <<EOF
---
name: invalid
$scalar
---
EOF
    run_fail "rejects malformed description scalar: $scalar" "description"
done

new_fixture
mkdir -p "$FIXTURE/vendor/example/unclosed"
cat >"$FIXTURE/vendor/example/unclosed/SKILL.md" <<'EOF'
---
name: unclosed
description: The closing delimiter is missing.
EOF
run_fail "requires a closing frontmatter delimiter" "missing closing YAML frontmatter delimiter"

new_fixture
mkdir -p "$FIXTURE/lefant/shared" "$FIXTURE/vendor/example/shared"
cat >"$FIXTURE/lefant/shared/SKILL.md" <<'EOF'
---
name: shared
description: Custom skill.
---
EOF
cat >"$FIXTURE/vendor/example/shared/SKILL.md" <<'EOF'
---
name: shared
description: Vendored skill.
---
EOF
run_fail "rejects duplicate names across lefant and vendor trees" "duplicate skill name 'shared'"

echo "check-vendor-layout tests passed"
