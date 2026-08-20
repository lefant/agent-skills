#!/bin/bash
# scripts/update-vendor.sh
# Fetches upstream skills into vendor/ directory for review

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/vendor"
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

fetch_file() {
    local repo=$1
    local file_path=$2
    local target_file=$3

    echo "Fetching $repo -> $file_path"
    if ! git clone --depth 1 --filter=blob:none --sparse "https://github.com/$repo.git" "$TEMP_DIR/repo" 2>/dev/null; then
        echo "  Warning: Failed to clone $repo, skipping..."
        return 1
    fi

    if ! git -C "$TEMP_DIR/repo" sparse-checkout set --no-cone "$file_path" 2>/dev/null; then
        echo "  Warning: Path $file_path not found in $repo, skipping..."
        rm -rf "$TEMP_DIR/repo"
        return 1
    fi

    if [[ ! -f "$TEMP_DIR/repo/$file_path" ]]; then
        echo "  Warning: Path $file_path not found in $repo, skipping..."
        rm -rf "$TEMP_DIR/repo"
        return 1
    fi

    mkdir -p "$(dirname "$target_file")"
    cp "$TEMP_DIR/repo/$file_path" "$target_file"
    rm -rf "$TEMP_DIR/repo"
    echo "  -> $target_file"
}

fetch_skillset() {
    local repo=$1
    local source_base=$2
    local target_base=$3
    shift 3
    local names=("$@")
    local sparse_paths=()

    echo "Fetching $repo -> $source_base/{${names[*]}}"
    if ! git clone --depth 1 --filter=blob:none --sparse "https://github.com/$repo.git" "$TEMP_DIR/repo" 2>/dev/null; then
        echo "  Warning: Failed to clone $repo, skipping..."
        return 1
    fi

    for name in "${names[@]}"; do
        sparse_paths+=("$source_base/$name")
    done

    if ! git -C "$TEMP_DIR/repo" sparse-checkout set "${sparse_paths[@]}" 2>/dev/null; then
        echo "  Warning: One or more paths not found in $repo, skipping..."
        rm -rf "$TEMP_DIR/repo"
        return 1
    fi

    mkdir -p "$target_base"
    for name in "${names[@]}"; do
        rm -rf "$target_base/$name"
        if [[ ! -d "$TEMP_DIR/repo/$source_base/$name" ]]; then
            echo "  Warning: Path $source_base/$name not found in $repo, skipping..."
            continue
        fi
        cp -r "$TEMP_DIR/repo/$source_base/$name" "$target_base/$name"
        echo "  -> $target_base/$name"
    done

    rm -rf "$TEMP_DIR/repo"
}

apply_post_fetch_fixes() {
    python - "$REPO_ROOT" <<'PY'
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])

replacements = [
    (Path('vendor/dz0ny/devenv/SKILL.md'), 'name: devenv-migration', 'name: devenv'),
    (Path('vendor/anthropics/pdf/SKILL.md'), 'see REFERENCE.md. If you need to fill out a PDF form, read FORMS.md and follow its instructions.', 'see reference.md. If you need to fill out a PDF form, read forms.md and follow its instructions.'),
    (Path('vendor/anthropics/pdf/SKILL.md'), '| Fill PDF forms | pdf-lib or pypdf (see FORMS.md) | See FORMS.md |', '| Fill PDF forms | pdf-lib or pypdf (see forms.md) | See forms.md |'),
    (Path('vendor/anthropics/pdf/SKILL.md'), '- For advanced pypdfium2 usage, see REFERENCE.md\n- For JavaScript libraries (pdf-lib), see REFERENCE.md\n- If you need to fill out a PDF form, follow the instructions in FORMS.md\n- For troubleshooting guides, see REFERENCE.md', '- For advanced pypdfium2 usage, see reference.md\n- For JavaScript libraries (pdf-lib), see reference.md\n- If you need to fill out a PDF form, follow the instructions in forms.md\n- For troubleshooting guides, see reference.md'),
    (Path('vendor/dz0ny/devenv/README.md'), 'devenv-migration/', 'devenv/'),
    (Path('vendor/remotion-dev/remotion-best-practices/SKILL.md'), './rules/sound-effects.md', './rules/sfx.md'),
    (Path('vendor/remotion-dev/remotion-best-practices/rules/voiceover.md'), './calculate-metadata)', './calculate-metadata.md)'),
    (Path('vendor/remotion-dev/remotion-best-practices/SKILL.md'), 'You can render a single frame with the CLI to sanity-check layout, colors, or timing.  ', 'You can render a single frame with the CLI to sanity-check layout, colors, or timing.'),
    (Path('vendor/marimo-team/marimo-notebook/SKILL.md'), 'For marimo notebooks that run in width=columns [SQL.md](references/COLUMNS.md)', 'For marimo notebooks that use columns, see [COLUMNS.md](references/COLUMNS.md)'),
    (Path('vendor/marimo-team/marimo-notebook/references/COLUMNS.md'), '    # This cell is in column 2 \n', '    # This cell is in column 2\n'),
    (Path('vendor/marimo-team/marimo-pair/SKILL.md'), '`edit_cell` change notebook structure only. Use `run_cell` to execute. \n', '`edit_cell` change notebook structure only. Use `run_cell` to execute.\n'),
    (Path('vendor/steipete/video-transcript-downloader/SKILL.md'), 'description: "yt-dlp downloads: video, audio, subtitles, transcripts, clips, playlists."', 'description: Download videos, audio, subtitles, and clean paragraph-style transcripts from YouTube and any other yt-dlp supported site. Use when asked to “download this video”, “save this clip”, “rip audio”, “get subtitles”, “get transcript”, or to troubleshoot yt-dlp/ffmpeg and formats/playlists.'),
    (Path('vendor/steipete/video-transcript-downloader/SKILL.md'), '`./scripts/vtd.js` can:', '`node {baseDir}/scripts/vtd.js` can:'),
    (Path('vendor/steipete/video-transcript-downloader/SKILL.md'), 'cd ~/Projects/agent-scripts/skills/video-transcript-downloader && npm ci', 'cd {baseDir} && npm ci  # Requires Node.js 20+'),
    (Path('vendor/steipete/video-transcript-downloader/SKILL.md'), './scripts/vtd.js', 'node {baseDir}/scripts/vtd.js'),
    (Path('vendor/steipete/markdown-converter/SKILL.md'), 'description: "Markdown conversion: PDF, Office, HTML, data, OCR, audio, ZIP, YouTube."', 'description: Convert documents and files to Markdown using markitdown. Use when converting PDF, Word (.docx), PowerPoint (.pptx), Excel (.xlsx, .xls), HTML, CSV, JSON, XML, images (with EXIF/OCR), audio (with transcription), ZIP archives, YouTube URLs, or EPubs to Markdown format for LLM processing or text analysis.'),
    (Path('vendor/vercel-labs/vercel-react-best-practices/AGENTS.md'), './async-defer-await.md', './rules/async-defer-await.md'),
    (Path('vendor/vercel-labs/vercel-react-best-practices/AGENTS.md'), './async-cheap-condition-before-await.md', './rules/async-cheap-condition-before-await.md'),
    (Path('vendor/openclaw/tavily-search/SKILL.md'), 'node scripts/search.mjs', 'node {baseDir}/scripts/search.mjs'),
    (Path('vendor/andrewyng/get-api-docs/SKILL.md'), 'If this results in an error showing that chub does not exist, then install it first, and run it\nagain. If the environment has node, npm, network access, and package-manager permission,\ninstall it as follows:', 'If this shows that chub is unavailable, ask the user before installing it globally. After approval, and only if the environment has Node.js, npm, network access, and package-manager permission, install it as follows:'),
    (Path('vendor/andrewyng/get-api-docs/SKILL.md'), 'Additionally, to help all developers, give feedback on the documentation using chub feedback, following\nthe instructions in chub --help . Do not include secrets, source code, private architecture details,\nor other sensitive information in feedback comments.', 'Additionally, ask the user before sending documentation feedback. After approval, use `chub feedback` according to `chub --help`. Do not include secrets, source code, private architecture details, or other sensitive information in feedback comments.'),
    (Path('vendor/JuliusBrussee/caveman/SKILL.md'), 'Supports intensity levels: lite, full (default), ultra,\n  wenyan-lite, wenyan-full, wenyan-ultra.', 'Supports intensity levels: lite (default in the lefant bundle), full, ultra,\n  wenyan-lite, wenyan-full, wenyan-ultra.'),
    (Path('vendor/JuliusBrussee/caveman/SKILL.md'), 'Default: **full**. Switch: `/caveman lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra|off`.', 'Default: **lite**. Switch: `/caveman lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra|off`.'),
    (Path('vendor/JuliusBrussee/caveman/README.md'), '| `lite` | Drop filler/hedging. Sentences stay full. Professional but tight. |\n| `full` | Default. Drop articles, fragments OK, short synonyms. |', '| `lite` | Default in the lefant bundle. Drop filler/hedging. Sentences stay full. Professional but tight. |\n| `full` | Drop articles, fragments OK, short synonyms. |'),
    (Path('vendor/JuliusBrussee/caveman/README.md'), '/caveman              # full mode (default)', '/caveman              # lite mode (default in the lefant bundle)'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), '| **Lite** | `/caveman lite` | Drop filler. Keep sentence structure. |', '| **Lite** | `/caveman` or `/caveman lite` | Drop filler. Keep sentence structure. Default in lefant bundle. |'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), '| **Full** | `/caveman` | Drop articles, filler, pleasantries, hedging. Fragments OK. Default. |', '| **Full** | `/caveman full` | Drop articles, filler, pleasantries, hedging. Fragments OK. Classic caveman. |'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), 'Default mode = `full`. Change it:', 'Default mode = `lite`. Change it:'),
    (Path('vendor/JuliusBrussee/caveman-help/SKILL.md'), 'Resolution: env var > config file > `full`.', 'Resolution: env var > config file > `lite`.'),
    (Path('vendor/JuliusBrussee/caveman-help/README.md'), '  /caveman              full (default)\n  /caveman lite         lighter', '  /caveman              lite (default in the lefant bundle)\n  /caveman full         classic caveman\n  /caveman lite         lighter'),
    (Path('vendor/JuliusBrussee/caveman-commit/README.md'), 'No AI attribution, no "this commit does X", no emoji unless the project uses them.', 'No AI attribution unless the project requires it, no "this commit does X", no emoji unless the project uses them.'),
    (Path('vendor/JuliusBrussee/caveman/README.md'), '\n- [Caveman README](../../README.md): repo overview, install, benchmarks', ''),
    (Path('vendor/JuliusBrussee/caveman-commit/README.md'), '\n- [Caveman README](../../README.md) — repo overview', ''),
    (Path('vendor/JuliusBrussee/caveman-help/README.md'), '\n- [Caveman README](../../README.md) — repo overview', ''),
    (Path('vendor/JuliusBrussee/caveman-review/README.md'), '\n- [Caveman README](../../README.md) — repo overview', ''),
    (Path('vendor/JuliusBrussee/caveman-compress/SKILL.md'), '1. The compression scripts live in `scripts/` (adjacent to this SKILL.md). If the path is not immediately available, search for `scripts/__main__.py` next to this SKILL.md.', '1. The compression scripts live in `scripts/` (adjacent to this SKILL.md). If the path is not immediately available, search for `{baseDir}/scripts/__main__.py`.'),
    (Path('vendor/JuliusBrussee/caveman-compress/SKILL.md'), 'python3 -m scripts <absolute_filepath>', 'cd {baseDir} && python3 -m scripts <absolute_filepath>'),
    (Path('vendor/woosal1337/ste-writing/SKILL.md'), 'python3 ste-lint.py draft.md            # flavored target: under 2.5 per 100 words\npython3 ste-lint.py --strict draft.md   # strict target: under 1.5 per 100 words', 'python3 {baseDir}/ste-lint.py draft.md            # flavored target: under 2.5 per 100 words\npython3 {baseDir}/ste-lint.py --strict draft.md   # strict target: under 1.5 per 100 words'),
    (Path('vendor/woosal1337/ste-writing/ste-lint.py'), '    longs = [(wc(s), s) for s in sents if wc(s) > 20]\n    v["long_sentence(>20w)"] = len(longs)', '    sentence_limit = 20 if strict else 25\n    longs = [(wc(s), s) for s in sents if wc(s) > sentence_limit]\n    v[f"long_sentence(>{sentence_limit}w)"] = len(longs)'),
    (Path('vendor/woosal1337/ste-writing/ste-lint.py'), '    v["contraction"] = len(re.findall(r"\\b\\w+[\'’](?:t|re|ve|ll|d|s|m)\\b", text))', '    v["contraction"] = len(re.findall(\n        r"\\b(?:\\w+[\'’](?:t|re|ve|ll|d|m)|(?:he|here|how|it|let|she|that|there|what|when|where|who|why)[\'’]s)\\b",\n        text, re.I))'),
    (Path('vendor/humanlayer/show-me/SKILL.md'), 'Then open it for the user:\n\n```\nBash(open path/to/show-me-{description}.html)\n```', 'Then open it for the user with the host\'s available browser or file-opening capability. If none is available, return the file path:\n\n```text\npath/to/show-me-{description}.html\n```'),
]

for path, old, new in replacements:
    path = repo_root / path
    if not path.exists():
        continue
    text = path.read_text()
    if old in text:
        path.write_text(text.replace(old, new))

required_local_snippets = {
    Path('vendor/JuliusBrussee/caveman/SKILL.md'): (
        'lite (default in the lefant bundle)',
        'Default: **lite**.',
    ),
    Path('vendor/JuliusBrussee/caveman-help/SKILL.md'): (
        'Default mode = `lite`.',
        'Resolution: env var > config file > `lite`.',
    ),
    Path('vendor/JuliusBrussee/caveman-compress/SKILL.md'): (
        'cd {baseDir} && python3 -m scripts <absolute_filepath>',
    ),
    Path('vendor/andrewyng/get-api-docs/SKILL.md'): (
        'ask the user before installing it globally',
        'ask the user before sending documentation feedback',
    ),
    Path('vendor/steipete/markdown-converter/SKILL.md'): (
        'Use when converting PDF',
    ),
    Path('vendor/steipete/video-transcript-downloader/SKILL.md'): (
        'Use when asked to “download this video”',
        'node {baseDir}/scripts/vtd.js',
        'Requires Node.js 20+',
    ),
    Path('vendor/marimo-team/marimo-notebook/SKILL.md'): (
        'see [COLUMNS.md](references/COLUMNS.md)',
    ),
}
for relative_path, snippets in required_local_snippets.items():
    path = repo_root / relative_path
    if not path.is_file():
        raise SystemExit(f'Post-fetch fix failed: {path} does not exist')
    text = path.read_text()
    missing = [snippet for snippet in snippets if snippet not in text]
    if missing:
        raise SystemExit(
            f'Post-fetch fix failed: {path} is missing required local snippet(s): '
            + ', '.join(missing)
        )

remotion_root = repo_root / 'vendor/remotion-dev/remotion-best-practices'
if remotion_root.is_dir():
    for path in remotion_root.rglob('*.md'):
        text = path.read_text()
        normalized = re.sub(r'[ \t]+$', '', text, flags=re.MULTILINE)
        normalized = re.sub(r'^ +(?=\t)', '', normalized, flags=re.MULTILINE)
        if normalized != text:
            path.write_text(normalized)

zfc_path = repo_root / 'vendor/lambdamechanic/zfc/SKILL.md'
if zfc_path.exists():
    text = zfc_path.read_text()
    reference = '\n## Reference\n\n- [Steve Yegge, "Zero Framework Cognition: A way to build resilient AI applications"](https://medium.com/@steve-yegge/zero-framework-cognition-a-way-to-build-resilient-ai-applications-56b090ed3e69)\n'
    if 'zero-framework-cognition-a-way-to-build-resilient-ai-applications-56b090ed3e69' not in text:
        zfc_path.write_text(text.rstrip() + reference)

ste_skill_path = repo_root / 'vendor/woosal1337/ste-writing/SKILL.md'
required_ste_lint_commands = (
    'python3 {baseDir}/ste-lint.py draft.md',
    'python3 {baseDir}/ste-lint.py --strict draft.md',
)
if not ste_skill_path.is_file():
    raise SystemExit(f'Post-fetch fix failed: {ste_skill_path} does not exist')

ste_skill_text = ste_skill_path.read_text()
missing_commands = [
    command for command in required_ste_lint_commands if command not in ste_skill_text
]
if missing_commands:
    raise SystemExit(
        f'Post-fetch fix failed: {ste_skill_path} is missing required command(s): '
        + ', '.join(missing_commands)
    )

ste_lint_path = repo_root / 'vendor/woosal1337/ste-writing/ste-lint.py'
required_ste_lint_snippets = (
    'sentence_limit = 20 if strict else 25',
    'v[f"long_sentence(>{sentence_limit}w)"] = len(longs)',
    "(?:he|here|how|it|let|she|that|there|what|when|where|who|why)['’]s",
)
if not ste_lint_path.is_file():
    raise SystemExit(f'Post-fetch fix failed: {ste_lint_path} does not exist')

ste_lint_text = ste_lint_path.read_text()
missing_snippets = [
    snippet for snippet in required_ste_lint_snippets if snippet not in ste_lint_text
]
if missing_snippets:
    raise SystemExit(
        f'Post-fetch fix failed: {ste_lint_path} is missing required local fixes: '
        + ', '.join(missing_snippets)
    )
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
fetch_skill "remotion-dev/skills" "skills/remotion-best-practices" "$VENDOR_DIR/remotion-dev/remotion-best-practices" || true

# HumanLayer - show-me
fetch_skill "humanlayer/skills" "plugins/show-me/skills/show-me" "$VENDOR_DIR/humanlayer/show-me" || true
fetch_file "humanlayer/skills" "LICENSE" "$VENDOR_DIR/humanlayer/LICENSE" || true

# Developer Kit
fetch_skill "giuseppe-trisciuoglio/developer-kit" "plugins/developer-kit-typescript/skills/shadcn-ui" "$VENDOR_DIR/giuseppe-trisciuoglio/shadcn-ui" || true

# Superpowers (disabled for now)
# fetch_skill "obra/superpowers" "skills/brainstorming" "$VENDOR_DIR/obra/brainstorming"
# fetch_skill "obra/superpowers" "skills/using-superpowers" "$VENDOR_DIR/obra/using-superpowers"

# Context Hub
fetch_skill "andrewyng/context-hub" "cli/skills/get-api-docs" "$VENDOR_DIR/andrewyng/get-api-docs" || true

# Context7
fetch_skill "intellectronica/agent-skills" "skills/context7" "$VENDOR_DIR/intellectronica/context7" || true

# exe.dev
fetch_skill "boldsoftware/exe.dev" "skill" "$VENDOR_DIR/boldsoftware/using-exe-dev" || true

# marimo
fetch_skill "marimo-team/skills" "skills/marimo-notebook" "$VENDOR_DIR/marimo-team/marimo-notebook" || true
fetch_skill "marimo-team/marimo-pair" "skills/marimo-pair" "$VENDOR_DIR/marimo-team/marimo-pair" || true

# Mitsuhiko - agent-stuff
fetch_skill "mitsuhiko/agent-stuff" "skills/tmux" "$VENDOR_DIR/mitsuhiko/tmux" || true
# Upstream removed skills/mermaid; retain the last reviewed snapshot until a replacement source is chosen.
fetch_skill "mitsuhiko/agent-stuff" "skills/librarian" "$VENDOR_DIR/mitsuhiko/librarian" || true

# ArtemXTech - TaskNotes
fetch_skill "ArtemXTech/personal-os-skills" "skills/tasknotes" "$VENDOR_DIR/ArtemXTech/tasknotes" || true

# ast-grep
fetch_skill "ast-grep/agent-skill" "ast-grep/skills/ast-grep" "$VENDOR_DIR/ast-grep/ast-grep" || true

# openclaw - tavily-search
# Source repository is unavailable; retain the last reviewed v1.0.0 snapshot.

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
fetch_skill "JuliusBrussee/caveman" "skills/caveman-compress" "$VENDOR_DIR/JuliusBrussee/caveman-compress" || true

# lambdamechanic - skills
fetch_skill "lambdamechanic/skills" "zfc" "$VENDOR_DIR/lambdamechanic/zfc" || true

# woosal1337 - ste-writing
fetch_file "woosal1337/blog" "videos/ep01-the-cure-for-ai-slop/ste-writing-skill.md" "$VENDOR_DIR/woosal1337/ste-writing/SKILL.md" || true
fetch_file "woosal1337/blog" "videos/ep01-the-cure-for-ai-slop/ste-recurring-errors.md" "$VENDOR_DIR/woosal1337/ste-writing/ste-recurring-errors.md" || true
fetch_file "woosal1337/blog" "videos/ep01-the-cure-for-ai-slop/ste-lint.py" "$VENDOR_DIR/woosal1337/ste-writing/ste-lint.py" || true
fetch_file "woosal1337/blog" "LICENSE" "$VENDOR_DIR/woosal1337/LICENSE" || true

# Pulumi - agent-skills
rm -rf "$VENDOR_DIR/pulumi"
fetch_skillset "pulumi/agent-skills" "migration/skills" "$VENDOR_DIR/pulumi" \
    pulumi-terraform-to-pulumi \
    pulumi-cdk-to-pulumi \
    cloudformation-to-pulumi \
    pulumi-arm-to-pulumi || true
fetch_skillset "pulumi/agent-skills" "pulumi/skills" "$VENDOR_DIR/pulumi" \
    pulumi-overview \
    pulumi-best-practices \
    pulumi-component \
    pulumi-automation-api \
    pulumi-esc \
    provider-upgrade \
    package-usage || true
fetch_skillset "pulumi/agent-skills" "package-maintenance/skills" "$VENDOR_DIR/pulumi" \
    pulumi-upgrade-provider \
    upstream-patches || true
fetch_skillset "pulumi/agent-skills" "delegation/skills" "$VENDOR_DIR/pulumi" \
    pulumi-neo-handoff || true

# Kepano - Obsidian skills
rm -rf "$VENDOR_DIR/kepano/obsidian-skills"
fetch_skillset "kepano/obsidian-skills" "skills" "$VENDOR_DIR/kepano" \
    defuddle \
    json-canvas \
    obsidian-bases \
    obsidian-cli \
    obsidian-markdown || true
fetch_file "kepano/obsidian-skills" "LICENSE" "$VENDOR_DIR/kepano/LICENSE" || true

apply_post_fetch_fixes

"$SCRIPT_DIR/check-show-me-vendor.py"
"$SCRIPT_DIR/check-ste-lint.sh"
"$SCRIPT_DIR/check-vendor-layout.sh"

echo ""
echo "Done. Review changes with: git diff vendor/"
