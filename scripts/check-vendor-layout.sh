#!/bin/bash
# Verify vendor layout and reject skill-name collisions across the bundle.

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
import re
import sys

errors = []
skills = []
seen_names = {}
INVALID = object()
BLOCK_HEADER = re.compile(r'^[>|](?:[+-][1-9]?|[1-9][+-]?)?$')
NUMBER = re.compile(
    r'''(?ix)
    [-+]?(?:
        0b[0-1_]+|0o[0-7_]+|0x[0-9a-f_]+|
        (?:[0-9][0-9_]*)?(?:\.[0-9_]*)?(?:e[-+]?[0-9]+)?|
        \.inf|\.nan
    )
    '''
)


def without_yaml_comment(value):
    for index, character in enumerate(value):
        if character == '#' and (index == 0 or value[index - 1].isspace()):
            return value[:index].rstrip()
    return value.rstrip()


def parse_quoted_scalar(value, quote):
    result = []
    index = 1
    escapes = {
        '0': '\0', 'a': '\a', 'b': '\b', 't': '\t', 'n': '\n', 'v': '\v',
        'f': '\f', 'r': '\r', 'e': '\x1b', ' ': ' ', '"': '"', '/': '/',
        '\\': '\\', 'N': '\u0085', '_': '\u00a0', 'L': '\u2028', 'P': '\u2029',
    }

    while index < len(value):
        character = value[index]
        if character == quote:
            if quote == "'" and index + 1 < len(value) and value[index + 1] == "'":
                result.append("'")
                index += 2
                continue
            remainder = value[index + 1:].strip()
            if remainder and not remainder.startswith('#'):
                return INVALID
            return ''.join(result)
        if quote == '"' and character == '\\':
            index += 1
            if index >= len(value):
                return INVALID
            escaped = value[index]
            if escaped in escapes:
                result.append(escapes[escaped])
            elif escaped in 'xuU':
                width = {'x': 2, 'u': 4, 'U': 8}[escaped]
                digits = value[index + 1:index + 1 + width]
                if len(digits) != width or not re.fullmatch(r'[0-9a-fA-F]+', digits):
                    return INVALID
                result.append(chr(int(digits, 16)))
                index += width
            else:
                return INVALID
        else:
            result.append(character)
        index += 1

    return INVALID


def parse_inline_scalar(value):
    value = value.strip()
    if not value or value.startswith('#'):
        return None
    if value[0] in "'\"":
        return parse_quoted_scalar(value, value[0])

    value = without_yaml_comment(value).strip()
    if not value or value == '~' or value.lower() == 'null':
        return None
    if value.lower() in {'true', 'false', 'yes', 'no', 'on', 'off'}:
        return INVALID
    if NUMBER.fullmatch(value) or re.fullmatch(r'\d{4}-\d{2}-\d{2}(?:[Tt ].*)?', value):
        return INVALID
    if value[0] in '[{&*!>|%@`':
        return INVALID
    return value


def parse_block_scalar(lines, start, header):
    indicator = without_yaml_comment(header).strip()
    if not BLOCK_HEADER.fullmatch(indicator):
        return INVALID, start + 1

    content = []
    index = start + 1
    while index < len(lines):
        line = lines[index]
        if line and not line[0].isspace():
            break
        content.append(line)
        index += 1

    explicit_indent = next((int(char) for char in indicator[1:] if char.isdigit()), None)
    nonblank = [line for line in content if line.strip()]
    if not nonblank:
        return '', index

    if explicit_indent is None:
        indent = len(nonblank[0]) - len(nonblank[0].lstrip(' '))
        if indent == 0:
            return INVALID, index
    else:
        indent = explicit_indent

    value_lines = []
    for line in content:
        if not line.strip():
            value_lines.append('')
            continue
        if line.startswith('\t') or len(line) - len(line.lstrip(' ')) < indent:
            return INVALID, index
        value_lines.append(line[indent:])
    return '\n'.join(value_lines), index


def read_frontmatter(path):
    lines = path.read_text(errors='replace').splitlines()
    if not lines or lines[0] != '---':
        errors.append(f'{path}: missing YAML frontmatter')
        return None, None

    try:
        closing = lines.index('---', 1)
    except ValueError:
        errors.append(f'{path}: missing closing YAML frontmatter delimiter')
        return None, None

    frontmatter = lines[1:closing]
    metadata = {}
    invalid_fields = set()
    index = 0
    while index < len(frontmatter):
        line = frontmatter[index]
        match = re.match(r'^([A-Za-z_][A-Za-z0-9_-]*):(?:[ \t]*(.*))?$', line)
        if not match:
            index += 1
            continue

        key, value = match.groups()
        if key not in {'name', 'description'}:
            index += 1
            continue
        if key in metadata:
            invalid_fields.add(key)

        value = value or ''
        if value.lstrip().startswith(('>', '|')):
            parsed, index = parse_block_scalar(frontmatter, index, value)
        else:
            parsed = parse_inline_scalar(value)
            index += 1
        metadata[key] = parsed

    for key in invalid_fields:
        metadata[key] = INVALID
    return metadata.get('name'), metadata.get('description')


def validate_skill(path):
    name, description = read_frontmatter(path)
    valid_name = isinstance(name, str) and bool(name.strip())
    valid_description = isinstance(description, str) and bool(description.strip())
    if not valid_name or name != path.parent.name:
        errors.append(f'{path}: frontmatter name {name!r} does not match directory {path.parent.name!r}')
    if not valid_description:
        errors.append(f'{path}: missing or invalid description')
    if valid_name:
        seen_names.setdefault(name, []).append(path)


for path in sorted(Path('lefant').glob('*/SKILL.md')):
    validate_skill(path)

for path in sorted(Path('vendor').rglob('SKILL.md')):
    skills.append(path)
    parts = path.parts
    if len(parts) != 4 or parts[0] != 'vendor' or parts[-1] != 'SKILL.md':
        errors.append(f'{path}: expected vendor/<source>/<skill>/SKILL.md')
        continue

    validate_skill(path)

for name, paths in sorted(seen_names.items()):
    if len(paths) > 1:
        joined = ', '.join(str(p) for p in paths)
        errors.append(f'duplicate skill name {name!r}: {joined}')

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
