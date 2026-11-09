#!/usr/bin/env bash
# Symlink each personal agent and command into the Claude config dir.
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
