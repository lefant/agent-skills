#!/usr/bin/env python3
"""Validate the vendored show-me skill's portable file-opening guidance."""

from pathlib import Path
import sys

PORTABLE_GUIDANCE = """Then open it for the user with the host's available browser or file-opening capability. If none is available, return the file path:

```text
path/to/show-me-{description}.html
```"""
FORBIDDEN_GUIDANCE = "Bash(open"


def validate(text: str, source: str) -> None:
    errors = []
    if PORTABLE_GUIDANCE not in text:
        errors.append("missing the complete portable file-opening guidance")
    if FORBIDDEN_GUIDANCE in text:
        errors.append("contains host-specific Bash(open ...) guidance")
    if errors:
        raise ValueError(f"{source}: {'; '.join(errors)}")


def check_regressions() -> None:
    fixtures = {
        "missing-complete-guidance": "with the host's available browser or file-opening capability",
        "portable-plus-forbidden-space": f"{PORTABLE_GUIDANCE}\n{FORBIDDEN_GUIDANCE} artifact.html)",
        "portable-plus-forbidden-tab": f"{PORTABLE_GUIDANCE}\n{FORBIDDEN_GUIDANCE}\tartifact.html)",
        "portable-plus-forbidden-newline": f"{PORTABLE_GUIDANCE}\n{FORBIDDEN_GUIDANCE}\nartifact.html)",
    }
    for name, fixture in fixtures.items():
        try:
            validate(fixture, name)
        except ValueError:
            continue
        raise AssertionError(f"regression fixture unexpectedly passed: {name}")


def main() -> int:
    default_path = Path(__file__).resolve().parents[1] / "vendor/humanlayer/show-me/SKILL.md"
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else default_path

    check_regressions()
    if not path.is_file():
        print(f"Error: show-me skill not found: {path}", file=sys.stderr)
        return 1

    try:
        validate(path.read_text(), str(path))
    except ValueError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    print("show-me vendor guidance OK.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
