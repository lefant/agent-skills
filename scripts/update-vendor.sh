#!/bin/bash
# scripts/update-vendor.sh
# Fetches upstream skills into vendor/ directory for review

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENDOR_DIR="$SCRIPT_DIR/../vendor"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

fetch_skill() {
    local repo=$1
    local skill_path=$2
    local target_dir=$3

    echo "Fetching $repo -> $skill_path"
    if ! git clone --depth 1 "https://github.com/$repo.git" "$TEMP_DIR/repo" 2>/dev/null; then
        echo "  Warning: Failed to clone $repo, skipping..."
        return 1
    fi

    if [[ ! -d "$TEMP_DIR/repo/$skill_path" ]]; then
        echo "  Warning: Path $skill_path not found in $repo, skipping..."
        rm -rf "$TEMP_DIR/repo"
        return 1
    fi

    rm -rf "$target_dir"
    mkdir -p "$(dirname "$target_dir")"
    cp -r "$TEMP_DIR/repo/$skill_path" "$target_dir"
    rm -rf "$TEMP_DIR/repo"
    echo "  -> $target_dir"
}

echo "Updating vendored skills..."
echo ""

# Vercel Labs - agent-skills
fetch_skill "vercel-labs/agent-skills" "skills/web-design-guidelines" "$VENDOR_DIR/vercel-labs/web-design-guidelines"
fetch_skill "vercel-labs/agent-skills" "skills/react-best-practices" "$VENDOR_DIR/vercel-labs/vercel-react-best-practices"

# Vercel Labs - agent-browser
fetch_skill "vercel-labs/agent-browser" "skills/agent-browser" "$VENDOR_DIR/vercel-labs/agent-browser"

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

# Obsidian (vendored as subtree, update with: git subtree pull --prefix=vendor/kepano/obsidian-skills https://github.com/kepano/obsidian-skills.git main --squash)
# Skills are at vendor/kepano/obsidian-skills/skills/{json-canvas,obsidian-bases,obsidian-markdown}

echo ""
echo "Done. Review changes with: git diff vendor/"
