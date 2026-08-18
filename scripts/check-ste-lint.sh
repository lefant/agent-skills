#!/bin/bash
# Verify local corrections to the vendored STE linter.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import importlib.util
from pathlib import Path

path = Path("vendor/woosal1337/ste-writing/ste-lint.py")
spec = importlib.util.spec_from_file_location("ste_lint", path)
ste_lint = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ste_lint)


def sentence(word_count):
    return " ".join(["word"] * word_count) + "."


for word_count, flavored_expected, strict_expected in (
    (20, 0, 0),
    (21, 0, 1),
    (25, 0, 1),
    (26, 1, 1),
):
    flavored = ste_lint.lint(sentence(word_count))["violations"]
    strict = ste_lint.lint(sentence(word_count), strict=True)["violations"]
    assert flavored["long_sentence(>25w)"] == flavored_expected, (
        word_count,
        flavored,
    )
    assert strict["long_sentence(>20w)"] == strict_expected, (
        word_count,
        strict,
    )

for possessive, contraction in (
    ("The server's status is clear.", "It's ready."),
    ("The server’s status is clear.", "It’s ready."),
):
    assert ste_lint.lint(possessive)["violations"]["contraction"] == 0, possessive
    assert ste_lint.lint(contraction)["violations"]["contraction"] == 1, contraction

print("STE linter regression checks OK.")
PY
