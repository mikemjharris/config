#!/usr/bin/env bash
# Symlink dotfiles from a local checkout into $HOME. Idempotent and unattended.
#
# Env vars:
#   SKIP_OMZ         set to 1 to skip oh-my-zsh install
#   SKIP_PLUGINS     set to 1 to skip vim/nvim plugin install (heavy, network)
#   SKIP_NPM_GLOBAL  set to 1 to skip global npm installs (yarn, mermaid-cli)

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing vim-plug for local plugins (run :PlugInstall in vim)"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ "${SKIP_OMZ:-0}" != "1" ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh (unattended, no chsh, keep zshrc)"
  # KEEP_ZSHRC=yes is important: otherwise the installer renames the existing
  # ~/.zshrc to ~/.zshrc.pre-oh-my-zsh and we lose anything install-linux.sh
  # or install.sh has already appended (rbenv init, aliases).
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

# Because KEEP_ZSHRC=yes skips loading oh-my-zsh from ~/.zshrc, add the init
# block ourselves (idempotent via marker).
OMZ_MARKER="# >>> oh-my-zsh init >>>"
touch "$HOME/.zshrc"
if [ -d "$HOME/.oh-my-zsh" ] && ! grep -qF "$OMZ_MARKER" "$HOME/.zshrc"; then
  echo "Appending oh-my-zsh init block to ~/.zshrc"
  cat >> "$HOME/.zshrc" <<'OMZ'
# >>> oh-my-zsh init >>>
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
# <<< oh-my-zsh init <<<
OMZ
fi

echo "Symlinking dotfiles into \$HOME"
ln -sfn "$REPO_ROOT/conf/.tmux.conf"            "$HOME/.tmux.conf"
ln -sfn "$REPO_ROOT/conf/.vimrc"                "$HOME/.vimrc"
ln -sfn "$REPO_ROOT/conf/.bash_aliases"         "$HOME/.bash_aliases"
ln -sfn "$REPO_ROOT/cli-tools/latest-branches.sh" "$HOME/latest-branches.sh"
ln -sfn "$REPO_ROOT/conf/.ctags"                "$HOME/.ctags"

echo "Linking vim templates"
mkdir -p "$HOME/.vim"
ln -sfn "$REPO_ROOT/conf/vim-templates" "$HOME/.vim/templates"

echo "Linking neovim config"
mkdir -p "$HOME/.config"
# Remove any existing real dir/symlink so the link is clean.
if [ -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
  rm -rf "$HOME/.config/nvim"
fi
ln -sfn "$REPO_ROOT/conf/new-nvim-setup" "$HOME/.config/nvim"

echo "Creating vim tmp folder"
mkdir -p "$HOME/tmp"

echo "Linking tmux session templates"
ln -sfn "$REPO_ROOT/conf/tmux" "$HOME/.tmux"

# Append aliases once (guarded by marker matching the one install.sh uses).
ALIASES_MARKER="# >>> mikemjharris/config:conf/setup_bash_aliases >>>"
touch "$HOME/.zshrc"
if ! grep -qF "$ALIASES_MARKER" "$HOME/.zshrc"; then
  echo "Appending aliases to ~/.zshrc"
  {
    echo "$ALIASES_MARKER"
    cat "$REPO_ROOT/conf/setup_bash_aliases"
    echo "# <<< mikemjharris/config:conf/setup_bash_aliases <<<"
  } >> "$HOME/.zshrc"
fi

echo "Configuring git global settings (idempotent)"
git config --global core.excludesfile "$REPO_ROOT/conf/.gitignore_global"
git config --global push.autoSetupRemote true

# zsh-z plugin (oh-my-zsh custom).
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ]; then
  mkdir -p "$ZSH_CUSTOM/plugins"
  git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z" || \
    echo "WARN: zsh-z clone failed (oh-my-zsh likely not installed yet)"
fi

if [ "${SKIP_PLUGINS:-0}" != "1" ]; then
  if command -v vim >/dev/null 2>&1; then
    echo "Installing vim plugins"
    yes | vim +PlugInstall +qall || true
  fi
  if command -v nvim >/dev/null 2>&1; then
    echo "Installing nvim plugins"
    yes | nvim +PlugInstall +qall || true
  fi
fi

if [ "${SKIP_NPM_GLOBAL:-0}" != "1" ] && command -v npm >/dev/null 2>&1; then
  echo "Installing global npm packages (yarn, mermaid-cli)"
  npm install -g yarn @mermaid-js/mermaid-cli || echo "WARN: global npm install failed"
fi

# Keyboard mappings — Linux desktop only.
if [ -d "$REPO_ROOT/conf/keyboard" ]; then
  ln -sfn "$REPO_ROOT/conf/keyboard" "$HOME/.mh_config"
fi
