---
date: 2026-02-04
status: completed
ticket: N/A
title: Bootstrap lefant/agent-skills Repository
author: Claude (Opus 4.5)
---

# Plan: Bootstrap lefant/agent-skills Repository

## Overview

Create a new repository `lefant/agent-skills` to centralize all skills for AI coding agents. This provides:
- Security review before inclusion
- Version control and pinning
- Single source for claude-code, codex, and opencode
- Clear separation between custom (`lefant/`) and vendored (`vendor/`) skills

## Directory Structure

```
lefant/agent-skills/
├── README.md
├── lefant/                          # Custom skills (migrated from plugins)
│   ├── github-access/
│   │   └── SKILL.md
│   ├── sentry/
│   │   ├── SKILL.md
│   │   └── scripts/                 # Supporting scripts
│   ├── architecture-decision-records/
│   │   ├── SKILL.md
│   │   └── template.md
│   ├── changelog-fragments/
│   │   ├── SKILL.md
│   │   ├── template.md
│   │   └── examples/
│   ├── feature-specs/
│   │   ├── SKILL.md
│   │   └── template.md
│   ├── mermaid-diagrams/
│   │   ├── SKILL.md
│   │   └── template.md
│   ├── test-analyzer/
│   │   ├── SKILL.md
│   │   └── ctrf-schema.json
│   └── youtube-transcript/
│       └── SKILL.md
├── vendor/                          # Vendored upstream skills (reviewed)
│   ├── README.md                    # Documents sources and update process
│   ├── vercel-labs/
│   │   ├── web-design-guidelines/
│   │   └── vercel-react-best-practices/
│   ├── vercel/
│   │   └── ai-sdk/
│   ├── anthropics/
│   │   ├── frontend-design/
│   │   └── skill-creator/
│   ├── remotion-dev/
│   │   └── remotion-best-practices/
│   ├── giuseppe-trisciuoglio/
│   │   └── shadcn-ui/
│   ├── obra/
│   │   ├── brainstorming/
│   │   └── using-superpowers/
│   ├── intellectronica/
│   │   └── context7/
│   └── mitsuhiko/
│       └── tmux/
└── scripts/
    └── update-vendor.sh             # Script to fetch/update vendored skills
```

## Implementation Steps

### Phase 1: Repository Setup [x]

#### Step 1.1: Create GitHub Repository [x]
```bash
gh repo create lefant/agent-skills --public --description "Curated AI agent skills for claude-code, codex, and opencode"
cd agent-skills
git init
```

#### Step 1.2: Create README.md [x]
```markdown
# lefant/agent-skills

Curated skills for AI coding agents (Claude Code, Codex, OpenCode).

## Structure

- `lefant/` - Custom skills developed in-house
- `vendor/` - Vendored skills from upstream repositories (reviewed for security)

## Usage

### With skills CLI
```bash
skills add /path/to/agent-skills --skill '*' -g -y -a claude-code -a codex -a opencode
```

### In Docker
Cloned to `/opt/lefant-agent-skills` and symlinked via entrypoint.

## Updating Vendored Skills

```bash
./scripts/update-vendor.sh
```
Then review changes before committing.
```

### Phase 2: Migrate Custom Skills from lefant-claude-code-plugins [x]

#### Step 2.1: Migrate github-access skill [x]
Source: `lefant-claude-code-plugins/github-access/skills/github-access/`
Target: `lefant/github-access/`

Files to copy:
- `SKILL.md`
- `references/` directory (curl-api.md, gh-commands.md, mcp-tools.md, troubleshooting.md)

#### Step 2.2: Migrate sentry skill [x]
Source: `lefant-claude-code-plugins/sentry/skills/sentry/`
Target: `lefant/sentry/`

Files to copy:
- `SKILL.md`

Note: The sentry scripts (`fetch-event.js`, `list-issues.js`, etc.) are called via the skill's instructions, so they need to be included:
- Copy `scripts/` directory alongside SKILL.md
- Update SKILL.md to reference relative script paths or document that sentry-cli is used

#### Step 2.3: Migrate skills from lefant plugin [x]
Source: `lefant-claude-code-plugins/lefant/skills/`
Target: `lefant/`

Skills to migrate:
1. `architecture-decision-records/` → copy SKILL.md, template.md
2. `changelog-fragments/` → copy SKILL.md, template.md, examples/
3. `feature-specs/` → copy SKILL.md, template.md
4. `mermaid-diagrams/` → copy SKILL.md, template.md
5. `test-analyzer/` → copy SKILL.md, ctrf-schema.json, ctrf-utils.sh
6. `youtube-transcript/` → copy SKILL.md

### Phase 3: Vendor Upstream Skills [x]

#### Step 3.1: Create vendor directory structure [x]
```bash
mkdir -p vendor/{vercel-labs,vercel,anthropics,remotion-dev,giuseppe-trisciuoglio,obra,intellectronica,mitsuhiko}
```

#### Step 3.2: Create update-vendor.sh script [x]
```bash
#!/bin/bash
# scripts/update-vendor.sh
# Fetches upstream skills into vendor/ directory for review

set -e

VENDOR_DIR="$(dirname "$0")/../vendor"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

fetch_skill() {
    local repo=$1
    local skill_path=$2
    local target_dir=$3

    echo "Fetching $repo -> $skill_path"
    git clone --depth 1 "https://github.com/$repo.git" "$TEMP_DIR/repo"
    rm -rf "$target_dir"
    mkdir -p "$(dirname "$target_dir")"
    cp -r "$TEMP_DIR/repo/$skill_path" "$target_dir"
    rm -rf "$TEMP_DIR/repo"
}

# Vercel Labs - agent-skills
fetch_skill "vercel-labs/agent-skills" "skills/web-design-guidelines" "$VENDOR_DIR/vercel-labs/web-design-guidelines"
fetch_skill "vercel-labs/agent-skills" "skills/react-best-practices" "$VENDOR_DIR/vercel-labs/vercel-react-best-practices"

# Vercel - AI SDK
fetch_skill "vercel/ai" "skills/use-ai-sdk" "$VENDOR_DIR/vercel/ai-sdk"

# Anthropic
fetch_skill "anthropics/skills" "skills/frontend-design" "$VENDOR_DIR/anthropics/frontend-design"
fetch_skill "anthropics/skills" "skills/skill-creator" "$VENDOR_DIR/anthropics/skill-creator"

# Remotion
fetch_skill "remotion-dev/skills" "skills/remotion" "$VENDOR_DIR/remotion-dev/remotion-best-practices"

# Developer Kit
fetch_skill "giuseppe-trisciuoglio/developer-kit" "skills/shadcn-ui" "$VENDOR_DIR/giuseppe-trisciuoglio/shadcn-ui"

# Superpowers
fetch_skill "obra/superpowers" "skills/brainstorming" "$VENDOR_DIR/obra/brainstorming"
fetch_skill "obra/superpowers" "skills/using-superpowers" "$VENDOR_DIR/obra/using-superpowers"

# Context7
fetch_skill "intellectronica/agent-skills" "skills/context7" "$VENDOR_DIR/intellectronica/context7"

# Tmux
fetch_skill "mitsuhiko/agent-stuff" "skills/tmux" "$VENDOR_DIR/mitsuhiko/tmux"

echo "Done. Review changes with: git diff vendor/"
```

#### Step 3.3: Run initial vendor fetch [x]
```bash
chmod +x scripts/update-vendor.sh
./scripts/update-vendor.sh
```

#### Step 3.4: Create vendor/README.md [x]
Document the source of each vendored skill and the update process.

### Phase 4: Finalize and Push [x]

#### Step 4.1: Add .gitignore [x]
```gitignore
# No ignores needed - we want everything tracked
```

#### Step 4.2: Initial commit [x]
```bash
git add -A
git commit -m "Initial commit: lefant skills + vendored upstream skills"
git push -u origin main
```

## Verification

After completion, verify:
1. Repository is accessible at `https://github.com/lefant/agent-skills`
2. All skills have valid SKILL.md files with proper frontmatter
3. `scripts/update-vendor.sh` runs successfully
4. Skills can be installed: `skills add https://github.com/lefant/agent-skills --skill '*' -g -y`

## Dependencies

- GitHub CLI (`gh`) for repo creation
- Git for cloning and committing
- Bash for update script

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Script paths in sentry skill may break | Update SKILL.md to use sentry-cli directly or include scripts |
| Vendored skills may have breaking changes | Review diff before committing updates |
| Skill name conflicts | Use namespaced directories (org/skill-name) |

## Estimated Effort

- Phase 1 (Setup): 15 minutes
- Phase 2 (Migrate): 30 minutes
- Phase 3 (Vendor): 20 minutes
- Phase 4 (Finalize): 10 minutes

Total: ~1.5 hours
