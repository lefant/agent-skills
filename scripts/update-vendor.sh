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
    if ! git clone --depth 1 --filter=blob:none --sparse "https://github.com/$repo.git" "$TEMP_DIR/repo" 2>/dev/null; then
        echo "  Warning: Failed to clone $repo, skipping..."
        return 1
    fi

    if ! git -C "$TEMP_DIR/repo" sparse-checkout set "$skill_path" 2>/dev/null; then
        echo "  Warning: Path $skill_path not found in $repo, skipping..."
        rm -rf "$TEMP_DIR/repo"
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

apply_post_fetch_fixes() {
    python - <<'PY'
from pathlib import Path

replacements = [
    (Path('vendor/dz0ny/devenv/SKILL.md'), 'name: devenv-migration', 'name: devenv'),
    (Path('vendor/anthropics/pdf/SKILL.md'), 'see REFERENCE.md. If you need to fill out a PDF form, read FORMS.md and follow its instructions.', 'see reference.md. If you need to fill out a PDF form, read forms.md and follow its instructions.'),
    (Path('vendor/anthropics/pdf/SKILL.md'), '| Fill PDF forms | pdf-lib or pypdf (see FORMS.md) | See FORMS.md |', '| Fill PDF forms | pdf-lib or pypdf (see forms.md) | See forms.md |'),
    (Path('vendor/anthropics/pdf/SKILL.md'), '- For advanced pypdfium2 usage, see REFERENCE.md\n- For JavaScript libraries (pdf-lib), see REFERENCE.md\n- If you need to fill out a PDF form, follow the instructions in FORMS.md\n- For troubleshooting guides, see REFERENCE.md', '- For advanced pypdfium2 usage, see reference.md\n- For JavaScript libraries (pdf-lib), see reference.md\n- If you need to fill out a PDF form, follow the instructions in forms.md\n- For troubleshooting guides, see reference.md'),
    (Path('vendor/dz0ny/devenv/README.md'), 'devenv-migration/', 'devenv/'),
    (Path('vendor/remotion-dev/remotion-best-practices/SKILL.md'), './rules/sound-effects.md', './rules/sfx.md'),
    (Path('vendor/remotion-dev/remotion-best-practices/rules/voiceover.md'), './calculate-metadata)', './calculate-metadata.md)'),
    (Path('vendor/vercel-labs/vercel-react-best-practices/AGENTS.md'), './async-defer-await.md', './rules/async-defer-await.md'),
    (Path('vendor/vercel-labs/vercel-react-best-practices/AGENTS.md'), './async-cheap-condition-before-await.md', './rules/async-cheap-condition-before-await.md'),
    (Path('vendor/openclaw/tavily-search/SKILL.md'), 'node scripts/search.mjs', 'node {baseDir}/scripts/search.mjs'),
    (Path('vendor/JuliusBrussee/caveman/SKILL.md'), 'Supports intensity levels: lite, full (default), ultra,\n  wenyan-lite, wenyan-full, wenyan-ultra.', 'Supports intensity levels: lite (default in the lefant bundle), full, ultra,\n  wenyan-lite, wenyan-full, wenyan-ultra.'),
    (Path('vendor/JuliusBrussee/caveman/SKILL.md'), 'Default: **full**. Switch: `/caveman lite|full|ultra`.', 'Default: **lite**. Switch: `/caveman lite|full|ultra`.'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), '| **Lite** | `/caveman lite` | Drop filler. Keep sentence structure. |', '| **Lite** | `/caveman` or `/caveman lite` | Drop filler. Keep sentence structure. Default in lefant bundle. |'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), '| **Full** | `/caveman` | Drop articles, filler, pleasantries, hedging. Fragments OK. Default. |', '| **Full** | `/caveman full` | Drop articles, filler, pleasantries, hedging. Fragments OK. Classic caveman. |'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), 'Default mode = `full`. Change it:', 'Default mode = `lite`. Change it:'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), 'Resolution: env var > config file > `full`.', 'Resolution: env var > config file > `lite`.'),
    (Path('vendor/JuliusBrussee/caveman-compress/SKILL.md'), '1. The compression scripts live in `caveman-compress/scripts/` (adjacent to this SKILL.md). If the path is not immediately available, search for `caveman-compress/scripts/__main__.py`.', '1. The compression scripts live in `scripts/` (adjacent to this SKILL.md). If the path is not immediately available, search for `{baseDir}/scripts/__main__.py`.'),
    (Path('vendor/JuliusBrussee/caveman-compress/SKILL.md'), 'cd caveman-compress && python3 -m scripts <absolute_filepath>', 'cd {baseDir} && python3 -m scripts <absolute_filepath>'),
]

for path, old, new in replacements:
    if not path.exists():
        continue
    text = path.read_text()
    if old in text:
        path.write_text(text.replace(old, new))
PY
}

echo "Updating vendored skills..."
echo ""

# Vercel Labs - agent-skills
fetch_skill "vercel-labs/agent-skills" "skills/web-design-guidelines" "$VENDOR_DIR/vercel-labs/web-design-guidelines" || true
fetch_skill "vercel-labs/agent-skills" "skills/react-best-practices" "$VENDOR_DIR/vercel-labs/vercel-react-best-practices" || true

# Vercel Labs - agent-browser
fetch_skill "vercel-labs/agent-browser" "skills/agent-browser" "$VENDOR_DIR/vercel-labs/agent-browser" || true

# Vercel - AI SDK
fetch_skill "vercel/ai" "skills/use-ai-sdk" "$VENDOR_DIR/vercel/ai-sdk" || true

# Anthropic
fetch_skill "anthropics/skills" "skills/frontend-design" "$VENDOR_DIR/anthropics/frontend-design" || true
fetch_skill "anthropics/skills" "skills/pdf" "$VENDOR_DIR/anthropics/pdf" || true
fetch_skill "anthropics/skills" "skills/skill-creator" "$VENDOR_DIR/anthropics/skill-creator" || true

# Remotion
fetch_skill "remotion-dev/skills" "skills/remotion" "$VENDOR_DIR/remotion-dev/remotion-best-practices" || true

# Developer Kit
fetch_skill "giuseppe-trisciuoglio/developer-kit" "plugins/developer-kit-typescript/skills/shadcn-ui" "$VENDOR_DIR/giuseppe-trisciuoglio/shadcn-ui" || true

# Superpowers (disabled for now)
# fetch_skill "obra/superpowers" "skills/brainstorming" "$VENDOR_DIR/obra/brainstorming"
# fetch_skill "obra/superpowers" "skills/using-superpowers" "$VENDOR_DIR/obra/using-superpowers"

# Context7
fetch_skill "intellectronica/agent-skills" "skills/context7" "$VENDOR_DIR/intellectronica/context7" || true

# Mitsuhiko - agent-stuff
fetch_skill "mitsuhiko/agent-stuff" "skills/tmux" "$VENDOR_DIR/mitsuhiko/tmux" || true
fetch_skill "mitsuhiko/agent-stuff" "skills/mermaid" "$VENDOR_DIR/mitsuhiko/mermaid" || true
fetch_skill "mitsuhiko/agent-stuff" "skills/librarian" "$VENDOR_DIR/mitsuhiko/librarian" || true

# ArtemXTech - TaskNotes
fetch_skill "ArtemXTech/personal-os-skills" "skills/tasknotes" "$VENDOR_DIR/ArtemXTech/tasknotes" || true

# ast-grep
fetch_skill "ast-grep/agent-skill" "ast-grep/skills/ast-grep" "$VENDOR_DIR/ast-grep/ast-grep" || true

# openclaw - tavily-search
fetch_skill "openclaw/skills" "skills/rajtejani61/tavily-web-search" "$VENDOR_DIR/openclaw/tavily-search" || true

# dz0ny - devenv
fetch_skill "dz0ny/devenv-claude" "skills/devenv" "$VENDOR_DIR/dz0ny/devenv" || true

# ChromeDevTools - chrome-devtools-cli
fetch_skill "ChromeDevTools/chrome-devtools-mcp" "skills/chrome-devtools-cli" "$VENDOR_DIR/ChromeDevTools/chrome-devtools-cli" || true

# steipete - agent-scripts
fetch_skill "steipete/agent-scripts" "skills/video-transcript-downloader" "$VENDOR_DIR/steipete/video-transcript-downloader" || true
fetch_skill "steipete/agent-scripts" "skills/markdown-converter" "$VENDOR_DIR/steipete/markdown-converter" || true

# JuliusBrussee - caveman
fetch_skill "JuliusBrussee/caveman" "skills/caveman" "$VENDOR_DIR/JuliusBrussee/caveman" || true
fetch_skill "JuliusBrussee/caveman" "skills/caveman-help" "$VENDOR_DIR/JuliusBrussee/caveman-help" || true
fetch_skill "JuliusBrussee/caveman" "skills/caveman-commit" "$VENDOR_DIR/JuliusBrussee/caveman-commit" || true
fetch_skill "JuliusBrussee/caveman" "skills/caveman-review" "$VENDOR_DIR/JuliusBrussee/caveman-review" || true
fetch_skill "JuliusBrussee/caveman" "caveman-compress" "$VENDOR_DIR/JuliusBrussee/caveman-compress" || true

# Obsidian (vendored as subtree, update with: git subtree pull --prefix=vendor/kepano/obsidian-skills https://github.com/kepano/obsidian-skills.git main --squash)
# Skills are at vendor/kepano/obsidian-skills/skills/{json-canvas,obsidian-bases,obsidian-markdown,obsidian-cli,defuddle}

apply_post_fetch_fixes

echo ""
echo "Done. Review changes with: git diff vendor/"
