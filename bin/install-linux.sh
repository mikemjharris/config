#!/usr/bin/env bash
# Linux setup script. Unattended-safe.
#
# Env vars:
#   SUDO            command used for privileged ops (default: sudo; set "" when already root)
#   SKIP_SERVICES   set to 1 to skip server packages (mysql, postgres, redis, etc.)
#   SKIP_DESKTOP    set to 1 to skip desktop/X11 packages
#   SKIP_DOCKER     set to 1 to skip Docker engine install (e.g. running inside a container)
#   SKIP_CHROME     set to 1 to skip Google Chrome install
#   SKIP_RBENV      set to 1 to skip rbenv install
#   SKIP_NVM        set to 1 to skip nvm/Node install
#   SKIP_GIT_CONFIG set to 1 to skip writing global git config

set -u
export DEBIAN_FRONTEND=noninteractive

SUDO="${SUDO-sudo}"

# sudo scrubs env vars by default, so wrap every apt-get call to re-inject
# DEBIAN_FRONTEND. Without this, packages like tzdata stall on interactive prompts.
apt_get() {
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get "$@"
}

apt_get update

CORE_PKGS="
git
curl
wget
ca-certificates
build-essential
zsh
tmux
mosh
less
jq
silversearcher-ag
ack-grep
htop
net-tools
xclip
locales
unzip
openssl
ffmpeg
imagemagick
ripgrep
fd-find
"

# Vim/Neovim. vim-gnome was removed after Ubuntu 18.04 — leave it in best-effort mode.
EDITOR_PKGS="vim vim-gtk3 neovim vim-gnome"

DEV_PKGS="
python3
python3-pip
python3-dev
python3-venv
nodejs
npm
libcurl4-openssl-dev
"

# Server / service packages — usually skipped in containers and CI.
SERVICE_PKGS="
nginx
redis-server
mysql-server
libmysqlclient-dev
postgresql
memcached
libmemcached-tools
elasticsearch
"

# Desktop / X11 — only relevant on a workstation.
DESKTOP_PKGS="
libgtk2.0-0
libgtk-3-0
libgbm-dev
libnotify-dev
libgconf-2-4
libnss3
libxss1
libasound2
libxtst6
xauth
xvfb
x11-apps
"

# Best-effort install: keep going if a package is missing on this Ubuntu version.
install_pkgs() {
  for pkg in $1; do
    apt_get install -y "$pkg" || echo "WARN: failed to install $pkg, continuing"
  done
}

install_pkgs "$CORE_PKGS"
install_pkgs "$EDITOR_PKGS"
install_pkgs "$DEV_PKGS"

if [ "${SKIP_SERVICES:-0}" != "1" ]; then
  install_pkgs "$SERVICE_PKGS"
fi

if [ "${SKIP_DESKTOP:-0}" != "1" ]; then
  install_pkgs "$DESKTOP_PKGS"
fi

# Python tooling for AWS / markdown preview.
python3 -m pip install --user --upgrade pip virtualenv awscli grip || echo "WARN: pip user installs failed"

# fzf — idempotent.
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-update-rc
fi

# Docker engine — skip inside containers / CI.
if [ "${SKIP_DOCKER:-0}" != "1" ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO apt-key add -
  $SUDO add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt_get update
  apt_get install -y docker-ce || echo "WARN: docker-ce install failed"
fi

# rbenv + ruby-build.
if [ "${SKIP_RBENV:-0}" != "1" ]; then
  RBENV_BUILD_DEPS="autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev libgmp-dev ruby-dev"
  install_pkgs "$RBENV_BUILD_DEPS"

  if [ ! -d "$HOME/.rbenv" ]; then
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
    git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
  fi

  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    touch "$rc"
    grep -q '.rbenv/bin' "$rc" || echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> "$rc"
    grep -q 'rbenv init' "$rc" || echo 'eval "$(rbenv init -)"' >> "$rc"
  done
fi

mkdir -p "$HOME/.apps"

# z — directory jumper.
if [ ! -d "$HOME/.apps/z" ]; then
  git clone https://github.com/rupa/z.git "$HOME/.apps/z"
fi
touch "$HOME/.zshrc"
grep -q '.apps/z/z.sh' "$HOME/.zshrc" || echo '. ~/.apps/z/z.sh' >> "$HOME/.zshrc"

# Google Chrome — desktop / Cypress only.
if [ "${SKIP_CHROME:-0}" != "1" ]; then
  TMP_DEB="$(mktemp --suffix=.deb)"
  if wget -q -O "$TMP_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
    apt_get install -y "$TMP_DEB" || echo "WARN: chrome install failed"
  fi
  rm -f "$TMP_DEB"
fi

# Global git config — skipped in CI so it doesn't overwrite real settings.
if [ "${SKIP_GIT_CONFIG:-0}" != "1" ]; then
  git config --global user.email "hello@mikemjharris.com"
  git config --global user.name "Mike Harris"
  git config --global push.default current
  git config --global core.editor "vim"
  git config --global merge.tool vimdiff
  git config --global merge.conflictstyle diff3
  git config --global mergetool.prompt false
  git config --global core.hooksPath '~/.git-templates'
  git config --global init.defaultBranch main
fi

# nvm + global npm packages.
if [ "${SKIP_NVM:-0}" != "1" ]; then
  if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  # shellcheck disable=SC1090
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  if command -v npm >/dev/null 2>&1; then
    npm install -g typescript @fsouza/prettierd || echo "WARN: global npm installs failed"
  fi
fi
