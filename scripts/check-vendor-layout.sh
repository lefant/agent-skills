#!/bin/bash
# Verify vendored skills are discoverable by wildcard skill installers.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failed=0

nested_skill_dirs=$(find vendor -type d -name skills -print | sort)
if [[ -n "$nested_skill_dirs" ]]; then
    echo "Error: nested vendor skills directories found." >&2
    echo "" >&2
    echo "$nested_skill_dirs" >&2
    echo "" >&2
    echo "Vendored skills must be flattened to vendor/<source>/<skill>/SKILL.md." >&2
    failed=1
fi

nested_skill_files=$(find vendor -path '*/skills/*/SKILL.md' -print | sort)
if [[ -n "$nested_skill_files" ]]; then
    echo "Error: SKILL.md files under nested skills/ containers found." >&2
    echo "" >&2
    echo "$nested_skill_files" >&2
    echo "" >&2
    echo "These are commonly missed by wildcard installs." >&2
    failed=1
fi

if ! python - <<'PY'
from pathlib import Path
import sys

errors = []
skills = []
seen_names = {}

for path in sorted(Path('vendor').rglob('SKILL.md')):
    skills.append(path)
    parts = path.parts
    if len(parts) != 4 or parts[0] != 'vendor' or parts[-1] != 'SKILL.md':
        errors.append(f'{path}: expected vendor/<source>/<skill>/SKILL.md')
        continue

    text = path.read_text(errors='replace')
    if not text.startswith('---\n'):
        errors.append(f'{path}: missing YAML frontmatter')
        continue

    frontmatter = text.split('---', 2)[1]
    name = None
    has_description = False
    for line in frontmatter.splitlines():
        if line.startswith('name:'):
            name = line.split(':', 1)[1].strip().strip('"\'')
        if line.startswith('description:'):
            has_description = True

    if name != path.parent.name:
        errors.append(f'{path}: frontmatter name {name!r} does not match directory {path.parent.name!r}')
    if not has_description:
        errors.append(f'{path}: missing description')
    if name:
        seen_names.setdefault(name, []).append(path)

for name, paths in sorted(seen_names.items()):
    if len(paths) > 1:
        joined = ', '.join(str(p) for p in paths)
        errors.append(f'duplicate vendor skill name {name!r}: {joined}')

if not skills:
    errors.append('no vendored SKILL.md files found')

if errors:
    for error in errors:
        print(f'Error: {error}', file=sys.stderr)
    sys.exit(1)

print(f'Vendor layout OK ({len(skills)} skills).')
PY
then
    failed=1
fi

if [[ "$failed" -ne 0 ]]; then
    exit 1
fi
