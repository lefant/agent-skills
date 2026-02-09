---
name: doc-audit
description: Audit documentation for quality issues including outdated information, broken references, contradictions, and inconsistencies. Use when asked to review docs, check documentation health, find stale content, validate cross-references, detect contradictions between documents, or ensure documentation consistency across a codebase.
---

# Documentation Audit Skill

Systematically analyze documentation for quality issues that erode trust and cause confusion.

## Audit Categories

### 1. Broken References
- Internal links pointing to non-existent files or anchors
- Code references to deleted/renamed functions, classes, files
- Image/asset references to missing files
- Cross-document references using outdated paths

### 2. Outdated Information
- Version numbers that don't match package.json/Cargo.toml/etc.
- API examples using deprecated patterns
- Installation instructions for old dependencies
- Screenshots/diagrams showing outdated UI
- Dates referencing past events as future

### 3. Contradictions
- Conflicting statements across documents
- README vs inline docs disagreement
- Config examples contradicting documented defaults
- Multiple sources of truth with different values

### 4. Inconsistencies
- Terminology drift (same concept, different names)
- Style inconsistencies (code block languages, heading levels)
- Formatting disparities across similar documents
- Incomplete migrations (old patterns alongside new)

## Audit Workflow

```
1. SCOPE: Identify documentation to audit
   └─> glob for *.md, *.mdx, *.rst, *.txt in docs/, README*, CONTRIBUTING*, etc.

2. INVENTORY: Catalog all documents with metadata
   └─> file path, last modified, word count, link count

3. EXTRACT: Pull references from each document
   └─> internal links, code refs, external URLs, images

4. VALIDATE: Check each reference resolves
   └─> file exists? anchor exists? code symbol exists?

5. CROSS-CHECK: Compare claims across documents
   └─> version numbers, config values, API signatures

6. REPORT: Generate findings by severity
   └─> critical (broken), warning (outdated), info (inconsistent)
```

## Running an Audit

### Script Selection

Choose based on project context:
- **TypeScript project** (has `package.json` or `tsconfig.json`): use `check-links.ts`
- **Python project** (has `pyproject.toml`, `setup.py`, or `requirements.txt`): use `check-links.py`
- **Default**: prefer TypeScript

### Quick Audit (single file)

**TypeScript:**
```bash
npx ts-node scripts/check-links.ts path/to/file.md
```

**Python:**
```bash
python scripts/check-links.py path/to/file.md
```

### Full Audit (documentation corpus)

**TypeScript:**
```bash
npx ts-node scripts/check-links.ts .
npx ts-node scripts/check-links.ts docs/
npx ts-node scripts/check-links.ts --json .  # JSON output
npx ts-node scripts/check-links.ts --fix .   # Show fix suggestions
```

**Python:**
```bash
python scripts/check-links.py .
python scripts/check-links.py --json .
python scripts/check-links.py --fix .
```

### Manual Discovery
```bash
# Find all documentation files
find . -name "*.md" -o -name "README*" | head -50

# Check for orphaned internal links
grep -roh '\[.*\]([^)]*\.md)' docs/ | sort | uniq -c | sort -rn
```

### Reference Validation

**Internal links**: Extract `[text](path)` patterns, verify target exists.

**Code references**: Match backtick references against actual codebase:
```bash
# Find all inline code refs
grep -oE '`[A-Za-z_][A-Za-z0-9_]*`' docs/*.md | sort | uniq

# Check if they exist in code
grep -r "function_name" src/
```

**Anchor links**: Verify `#heading-slug` targets exist in target file.

## Detecting Staleness

Documentation becomes stale when code changes but docs don't. Key detection strategies:

### Git-Based Staleness

Compare doc modification dates against related code:
```bash
# When was this doc last updated?
git log -1 --format="%ci" -- docs/api.md

# When was the code it documents last changed?
git log -1 --format="%ci" -- src/api/

# Find docs not updated in 6+ months
git log --all --format="%ci %s" --diff-filter=M -- "*.md" | head -20
```

### Code Reference Tracking

If docs reference specific files/functions, check if those changed more recently:
```bash
# Extract code paths mentioned in docs
grep -ohE 'src/[a-zA-Z0-9_/.-]+' docs/*.md | sort -u

# For each referenced file, compare timestamps
for ref in $(grep -ohE 'src/[a-zA-Z0-9_/.-]+' docs/api.md | sort -u); do
  echo "$ref: $(git log -1 --format='%ci' -- "$ref" 2>/dev/null || echo 'not found')"
done
```

### Staleness Indicators

Flag docs that mention:
- Specific dates in the past ("as of January 2025")
- Version numbers older than current release
- Deprecated features still documented as current
- "TODO", "FIXME", "WIP" markers left in published docs
- References to removed files/functions

### Recommended Workflow

1. List all docs with their last-modified date
2. For each doc, identify what code it describes
3. Compare timestamps - flag if code is newer than doc
4. Review flagged docs for accuracy

## Detecting Contradictions

### Version Mismatches
Compare version claims against source of truth:
```bash
# Package version
grep '"version"' package.json

# Documented version
grep -i "version" README.md docs/*.md
```

### Config Value Conflicts
Extract config examples, compare against defaults:
```bash
# Find config examples in docs
grep -A5 "config" docs/*.md

# Compare to actual defaults
grep -A10 "defaults" src/config.*
```

### API Signature Drift
Match documented function signatures against code:
```bash
# Documented API
grep -E "^\s*\w+\([^)]*\)" docs/api.md

# Actual implementation
grep -E "^(export )?(async )?(function|const) \w+" src/*.ts
```

## Inconsistency Detection

### Terminology Audit
Build a glossary of terms used, flag variations:
- "config" vs "configuration" vs "settings"
- "user" vs "account" vs "profile"
- "error" vs "exception" vs "failure"

### Style Consistency
Check for:
- Code fence languages (```js vs ```javascript)
- Heading hierarchy (no skipped levels)
- List marker style (- vs * vs 1.)
- Link style (inline vs reference)

## Report Format

Generate a structured report:

```markdown
# Documentation Audit Report

Generated: YYYY-MM-DD
Scope: docs/, README.md, CONTRIBUTING.md

## Summary
- Files audited: N
- Issues found: N (X critical, Y warnings, Z info)

## Critical Issues (Broken)
| File | Line | Issue | Details |
|------|------|-------|---------|
| docs/api.md | 45 | Dead link | `./old-file.md` not found |

## Warnings (Outdated)
| File | Line | Issue | Details |
|------|------|-------|---------|
| README.md | 12 | Version mismatch | Says 2.0, package.json has 3.1 |

## Info (Inconsistencies)
| File | Line | Issue | Details |
|------|------|-------|---------|
| docs/guide.md | 8 | Term variation | "config" (elsewhere: "configuration") |

## Recommendations
1. ...
2. ...
```

## Integration Patterns

### Pre-commit Hook
Run link validation before commits:
```bash
#!/bin/bash
# .git/hooks/pre-commit
find docs -name "*.md" -exec grep -l '\[.*\](.*\.md)' {} \; | \
  while read f; do
    # validate links in $f
  done
```

### CI Pipeline
Add documentation validation to CI:
```yaml
# .github/workflows/docs.yml
- name: Validate docs
  run: |
    # Check for broken links
    # Verify version consistency
    # Flag outdated content
```

### Scheduled Audits
Run weekly/monthly full audits to catch drift:
```bash
# cron: 0 9 * * 1 (every Monday 9am)
./scripts/doc-audit.sh > reports/doc-audit-$(date +%Y%m%d).md
```

## Severity Guidelines

**Critical** (must fix):
- Broken internal links (404 within docs)
- Missing referenced files
- Code examples that won't compile/run

**Warning** (should fix):
- Outdated version numbers
- Deprecated API usage in examples
- External links returning errors

**Info** (consider fixing):
- Terminology inconsistencies
- Style variations
- Minor formatting issues

## What NOT to Flag

- Intentional variations (branded terms)
- External links (unless 404)
- Spelling/grammar (use separate linter)
- Subjective style preferences
