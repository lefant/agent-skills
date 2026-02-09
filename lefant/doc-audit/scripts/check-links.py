#!/usr/bin/env python3
"""
Check markdown files for broken internal links and references.

Usage:
    python check-links.py [PATH]         # Check path (default: current dir)
    python check-links.py --json         # Output as JSON
    python check-links.py --fix          # Suggest fixes for broken links
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import NamedTuple
from urllib.parse import unquote, urlparse


class Issue(NamedTuple):
    file: str
    line: int
    severity: str  # critical, warning, info
    category: str  # broken-link, missing-anchor, missing-image, etc.
    message: str
    suggestion: str | None = None


def slugify(text: str) -> str:
    """Convert heading text to GitHub-style anchor slug."""
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[-\s]+', '-', text)
    return text


def extract_headings(content: str) -> set[str]:
    """Extract all heading anchors from markdown content."""
    headings = set()
    for match in re.finditer(r'^#{1,6}\s+(.+?)(?:\s*{#([^}]+)})?$', content, re.MULTILINE):
        text, explicit_id = match.groups()
        if explicit_id:
            headings.add(explicit_id)
        else:
            headings.add(slugify(text))
    return headings


def extract_links(content: str, file_path: Path) -> list[tuple[int, str, str]]:
    """Extract all links from markdown: (line_number, link_text, link_target)."""
    links = []
    in_code_block = False

    for i, line in enumerate(content.split('\n'), 1):
        # Track code blocks
        if line.strip().startswith('```'):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue

        # Skip inline code
        line_no_code = re.sub(r'`[^`]+`', '', line)

        # Markdown links: [text](url)
        for match in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', line_no_code):
            links.append((i, match.group(1), match.group(2)))
        # Reference-style links: [text][ref] or [ref]
        for match in re.finditer(r'\[([^\]]+)\]\[([^\]]*)\]', line_no_code):
            links.append((i, match.group(1), f'ref:{match.group(2) or match.group(1)}'))
    return links


def extract_images(content: str) -> list[tuple[int, str]]:
    """Extract all image references: (line_number, image_path)."""
    images = []
    in_code_block = False

    for i, line in enumerate(content.split('\n'), 1):
        if line.strip().startswith('```'):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue

        # Skip inline code
        line_no_code = re.sub(r'`[^`]+`', '', line)

        for match in re.finditer(r'!\[[^\]]*\]\(([^)]+)\)', line_no_code):
            images.append((i, match.group(1)))
    return images


def find_similar_files(target: str, search_dir: Path, max_results: int = 3) -> list[str]:
    """Find files with similar names for suggestions."""
    target_name = Path(target).name.lower()
    candidates = []
    for f in search_dir.rglob('*'):
        if f.is_file() and f.suffix in ('.md', '.mdx', '.rst', '.txt'):
            score = 0
            name = f.name.lower()
            if target_name in name or name in target_name:
                score += 2
            if f.suffix == Path(target).suffix:
                score += 1
            if score > 0:
                candidates.append((score, str(f.relative_to(search_dir))))
    candidates.sort(reverse=True)
    return [c[1] for c in candidates[:max_results]]


def check_file(file_path: Path, all_files: dict[str, Path], root: Path) -> list[Issue]:
    """Check a single markdown file for issues."""
    issues = []
    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        return [Issue(str(file_path), 0, 'critical', 'read-error', f'Cannot read file: {e}')]

    file_dir = file_path.parent
    headings = extract_headings(content)

    # Check links
    for line_num, text, target in extract_links(content, file_path):
        # Skip reference-style links (would need separate pass)
        if target.startswith('ref:'):
            continue

        # Skip external links
        parsed = urlparse(target)
        if parsed.scheme in ('http', 'https', 'mailto', 'ftp'):
            continue

        # Split path and anchor
        path_part, _, anchor = unquote(target).partition('#')

        if path_part:
            # Resolve relative path
            target_path = (file_dir / path_part).resolve()
            try:
                rel_target = target_path.relative_to(root)
            except ValueError:
                rel_target = target_path

            if not target_path.exists():
                similar = find_similar_files(path_part, root)
                suggestion = f"Did you mean: {', '.join(similar)}" if similar else None
                issues.append(Issue(
                    str(file_path.relative_to(root)),
                    line_num,
                    'critical',
                    'broken-link',
                    f"Link target not found: {path_part}",
                    suggestion
                ))
            elif anchor:
                # Check anchor in target file
                try:
                    target_content = target_path.read_text(encoding='utf-8')
                    target_headings = extract_headings(target_content)
                    if anchor not in target_headings:
                        issues.append(Issue(
                            str(file_path.relative_to(root)),
                            line_num,
                            'warning',
                            'missing-anchor',
                            f"Anchor #{anchor} not found in {path_part}",
                            f"Available anchors: {', '.join(sorted(target_headings)[:5])}" if target_headings else None
                        ))
                except Exception:
                    pass
        elif anchor:
            # Same-file anchor
            if anchor not in headings:
                issues.append(Issue(
                    str(file_path.relative_to(root)),
                    line_num,
                    'warning',
                    'missing-anchor',
                    f"Anchor #{anchor} not found in this file",
                    f"Available anchors: {', '.join(sorted(headings)[:5])}" if headings else None
                ))

    # Check images
    for line_num, img_path in extract_images(content):
        parsed = urlparse(img_path)
        if parsed.scheme in ('http', 'https', 'data'):
            continue

        target_path = (file_dir / unquote(img_path)).resolve()
        if not target_path.exists():
            issues.append(Issue(
                str(file_path.relative_to(root)),
                line_num,
                'critical',
                'missing-image',
                f"Image not found: {img_path}"
            ))

    return issues


def main():
    parser = argparse.ArgumentParser(description='Check markdown files for broken links')
    parser.add_argument('path', nargs='?', default='.', help='Path to check')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--fix', action='store_true', help='Show fix suggestions')
    args = parser.parse_args()

    root = Path(args.path).resolve()
    if not root.exists():
        print(f"Error: Path not found: {root}", file=sys.stderr)
        sys.exit(1)

    # Find all markdown files
    if root.is_file():
        md_files = [root]
        root = root.parent
    else:
        md_files = list(root.rglob('*.md')) + list(root.rglob('*.mdx'))

    # Build file index
    all_files = {str(f.relative_to(root)): f for f in md_files}

    # Check all files
    all_issues: list[Issue] = []
    for f in md_files:
        issues = check_file(f, all_files, root)
        all_issues.extend(issues)

    # Output
    if args.json:
        print(json.dumps([i._asdict() for i in all_issues], indent=2))
    else:
        if not all_issues:
            print(f"No issues found in {len(md_files)} files.")
            sys.exit(0)

        # Group by severity
        critical = [i for i in all_issues if i.severity == 'critical']
        warnings = [i for i in all_issues if i.severity == 'warning']
        info = [i for i in all_issues if i.severity == 'info']

        print(f"Found {len(all_issues)} issues in {len(md_files)} files\n")

        for label, issues in [('CRITICAL', critical), ('WARNING', warnings), ('INFO', info)]:
            if not issues:
                continue
            print(f"## {label} ({len(issues)})\n")
            for i in issues:
                print(f"  {i.file}:{i.line} [{i.category}]")
                print(f"    {i.message}")
                if args.fix and i.suggestion:
                    print(f"    -> {i.suggestion}")
                print()

    sys.exit(1 if all_issues else 0)


if __name__ == '__main__':
    main()
