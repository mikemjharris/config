#!/usr/bin/env bash
# Bootstrap dotfiles. Prefers local files when run from a checkout, falls back
# to curling from GitHub for the no-clone bootstrap case.
#
# Idempotent: re-running won't append duplicate aliases.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RAW_BASE="https://raw.githubusercontent.com/mikemjharris/config/main"

USE_LOCAL=0
if [ -f "$REPO_ROOT/conf/.vimrc" ]; then
  USE_LOCAL=1
fi

# fetch <relative-path> <dest>
fetch() {
  local rel="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ "$USE_LOCAL" = "1" ]; then
    cp "$REPO_ROOT/$rel" "$dest"
  else
    curl -fsSL "$RAW_BASE/$rel" -o "$dest"
  fi
}

# append_once <relative-path> <dest>: append source contents to dest, but only
# the first time (guarded by a marker line).
append_once() {
  local rel="$1" dest="$2"
  local marker="# >>> mikemjharris/config:$rel >>>"
  touch "$dest"
  if grep -qF "$marker" "$dest"; then
    return
  fi
  {
    echo "$marker"
    if [ "$USE_LOCAL" = "1" ]; then
      cat "$REPO_ROOT/$rel"
    else
      curl -fsSL "$RAW_BASE/$rel"
    fi
    echo "# <<< mikemjharris/config:$rel <<<"
  } >> "$dest"
}

echo "Installing vimrc, tmux conf, irbrc, tmux templates"
fetch conf/.vimrc        "$HOME/.vimrc"
fetch conf/.tmux.conf    "$HOME/.tmux.conf"
fetch conf/.irbrc        "$HOME/.irbrc"
fetch conf/tmux/session1 "$HOME/.tmux-session1"

echo "Appending aliases to ~/.bash_aliases / ~/.bashrc / ~/.zshrc"
append_once conf/.bash_aliases       "$HOME/.bash_aliases"
append_once conf/setup_bash_aliases  "$HOME/.bashrc"
append_once conf/setup_bash_aliases  "$HOME/.zshrc"

echo "Installing vim-plug"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing latest-branches helper"
fetch cli-tools/latest-branches.sh "$HOME/latest-branches.sh"
chmod +x "$HOME/latest-branches.sh" 2>/dev/null || true
