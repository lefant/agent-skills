#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$SKILL_DIR/references/upstream/agentskills"
CLONE_DIR="${AGENTSKILLS_CLONE_DIR:-$HOME/git/external/agentskills}"
REPO_URL="https://github.com/agentskills/agentskills"

mkdir -p "$(dirname -- "$CLONE_DIR")"
if [ ! -d "$CLONE_DIR/.git" ]; then
  git clone "$REPO_URL" "$CLONE_DIR"
else
  git -C "$CLONE_DIR" fetch --all --prune
  git -C "$CLONE_DIR" pull --ff-only
fi

mkdir -p \
  "$TARGET_DIR/docs/skill-creation" \
  "$TARGET_DIR/docs/client-implementation" \
  "$TARGET_DIR/skills-ref"

curl -fsSL https://agentskills.io/llms.txt -o "$TARGET_DIR/llms.txt"

cp "$CLONE_DIR/README.md" "$TARGET_DIR/README.md"
cp "$CLONE_DIR/docs/what-are-skills.mdx" "$TARGET_DIR/docs/what-are-skills.mdx"
cp "$CLONE_DIR/docs/specification.mdx" "$TARGET_DIR/docs/specification.mdx"
cp "$CLONE_DIR/docs/skill-creation/quickstart.mdx" "$TARGET_DIR/docs/skill-creation/quickstart.mdx"
cp "$CLONE_DIR/docs/skill-creation/best-practices.mdx" "$TARGET_DIR/docs/skill-creation/best-practices.mdx"
cp "$CLONE_DIR/docs/skill-creation/evaluating-skills.mdx" "$TARGET_DIR/docs/skill-creation/evaluating-skills.mdx"
cp "$CLONE_DIR/docs/skill-creation/optimizing-descriptions.mdx" "$TARGET_DIR/docs/skill-creation/optimizing-descriptions.mdx"
cp "$CLONE_DIR/docs/skill-creation/using-scripts.mdx" "$TARGET_DIR/docs/skill-creation/using-scripts.mdx"
cp "$CLONE_DIR/docs/client-implementation/adding-skills-support.mdx" "$TARGET_DIR/docs/client-implementation/adding-skills-support.mdx"
cp "$CLONE_DIR/skills-ref/README.md" "$TARGET_DIR/skills-ref/README.md"
cp "$CLONE_DIR/skills-ref/CLAUDE.md" "$TARGET_DIR/skills-ref/CLAUDE.md"
cp "$CLONE_DIR/skills-ref/pyproject.toml" "$TARGET_DIR/skills-ref/pyproject.toml"
cp "$CLONE_DIR/skills-ref/LICENSE" "$TARGET_DIR/skills-ref/LICENSE"

cat > "$TARGET_DIR/SOURCE.txt" <<EOF
Repository: $REPO_URL
Clone: $CLONE_DIR
Commit: $(git -C "$CLONE_DIR" rev-parse HEAD)
Fetched: $(date -u +%F)
Files:
- README.md
- llms.txt
- docs/what-are-skills.mdx
- docs/specification.mdx
- docs/skill-creation/quickstart.mdx
- docs/skill-creation/best-practices.mdx
- docs/skill-creation/evaluating-skills.mdx
- docs/skill-creation/optimizing-descriptions.mdx
- docs/skill-creation/using-scripts.mdx
- docs/client-implementation/adding-skills-support.mdx
- skills-ref/README.md
- skills-ref/CLAUDE.md
- skills-ref/pyproject.toml
- skills-ref/LICENSE
Method: scripts/update-agentskills-docs.sh copied curated upstream docs into references/upstream/agentskills
EOF

echo "Updated $TARGET_DIR" >&2
find "$TARGET_DIR" -type f | sort
