#!/usr/bin/env bash
# Symlink each personal agent, command and skill into the Claude config dir.
# Idempotent. Links file by file so other tools' agents and commands in the
# same folders (e.g. sw-toolbox) are left alone.
#
# Env vars:
#   CLAUDE_CONFIG_DIR  Claude config dir to install into (default ~/.claude)

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

link_files() {
  local kind="$1"
  local source_dir="$SCRIPT_DIR/$kind"
  local target_dir="$CLAUDE_DIR/$kind"

  mkdir -p "$target_dir"

  # Drop links to files that have since been removed or renamed in the repo.
  for link in "$target_dir"/mj-*.md; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
      rm "$link"
      echo "  Removed stale $(basename "$link")"
    fi
  done

  for file in "$source_dir"/*.md; do
    ln -sfn "$file" "$target_dir/$(basename "$file")"
    echo "  Linked $(basename "$file")"
  done
}

echo "Linking agents into $CLAUDE_DIR/agents"
link_files agents

echo "Linking commands into $CLAUDE_DIR/commands"
link_files commands

# Skills are folders: link each one whole, and install its npm packages if it has any.
echo "Linking skills into $CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/skills"
for link in "$CLAUDE_DIR"/skills/mj-*; do
  if [ -L "$link" ] && [ ! -e "$link" ]; then
    rm "$link"
    echo "  Removed stale $(basename "$link")"
  fi
done
for skill in "$SCRIPT_DIR"/skills/*/; do
  skill="${skill%/}"
  ln -sfn "$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
  echo "  Linked $(basename "$skill")"
  if [ -f "$skill/package.json" ] && command -v npm >/dev/null; then
    (cd "$skill" && PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install --silent --no-fund --no-audit) \
      && echo "    npm packages installed" || echo "    npm install failed in $skill" >&2
  fi
done

echo "Linking scripts into ~/.local/bin"
mkdir -p "$HOME/.local/bin"
for file in "$SCRIPT_DIR"/bin/*; do
  ln -sfn "$file" "$HOME/.local/bin/$(basename "$file")"
  echo "  Linked $(basename "$file")"
done
