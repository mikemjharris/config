#!/usr/bin/env bash
# Linux setup script. Unattended-safe. Tested on Ubuntu 22.04, 24.04 and 26.04.
#
# Env vars:
#   SUDO            command used for privileged ops (default: sudo; set "" when already root)
#   SKIP_SERVICES   set to 1 to skip server packages (mysql, postgres, redis, etc.)
#   SKIP_DESKTOP    set to 1 to skip desktop/X11 packages
#   SKIP_DOCKER     set to 1 to skip Docker engine install (e.g. running inside a container)
#   SKIP_CHROME     set to 1 to skip Google Chrome install
#   SKIP_RBENV      set to 1 to skip rbenv install
#   SKIP_NVM        set to 1 to skip nvm/Node install
#   SKIP_NEOVIM     set to 1 to skip installing the Neovim release build
#   SKIP_CHSH       set to 1 to skip making zsh the login shell
#   SKIP_GIT_CONFIG set to 1 to skip writing global git config

set -u
export DEBIAN_FRONTEND=noninteractive

SUDO="${SUDO-sudo}"
# The nvim config (conf/new-nvim-setup) needs 0.12+; distro packages lag behind.
NEOVIM_VERSION="v0.12.6"

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
ack
htop
net-tools
xclip
wl-clipboard
locales
unzip
openssl
ffmpeg
imagemagick
ripgrep
fd-find
lazygit
"

EDITOR_PKGS="vim vim-gtk3"

DEV_PKGS="
python3
python3-pip
python3-dev
python3-venv
pipx
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
"

# Desktop / X11 — only relevant on a workstation. a|b picks the first name the
# distro has: Ubuntu 24.04 renamed several libs with a t64 suffix.
DESKTOP_PKGS="
libgtk2.0-0t64|libgtk2.0-0
libgtk-3-0t64|libgtk-3-0
libgbm-dev
libnotify-dev
libnss3
libxss1
libasound2t64|libasound2
libxtst6
xauth
xvfb
x11-apps
"

# Install every package the distro knows about in one apt call, warning about
# any it doesn't, so a renamed package doesn't sink the rest of the list.
install_pkgs() {
  local available="" spec name found
  for spec in $1; do
    found=""
    for name in ${spec//|/ }; do
      if apt-cache show "$name" >/dev/null 2>&1; then
        found="$name"
        break
      fi
    done
    if [ -n "$found" ]; then
      available="$available $found"
    else
      echo "WARN: no package named $spec on this distro, skipping"
    fi
  done
  # shellcheck disable=SC2086
  [ -n "$available" ] && { apt_get install -y $available || echo "WARN: some packages failed to install"; }
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

# ~/.local/bin holds pipx apps and nvim. Ubuntu's ~/.profile only adds it for
# bash login shells, so make sure zsh gets it too.
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
touch "$HOME/.zshrc"
grep -q '.local/bin' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"

# Python CLI tools. pip --user is blocked on modern distros (PEP 668), so use pipx.
if command -v pipx >/dev/null 2>&1; then
  for tool in awscli grip; do
    pipx list --short 2>/dev/null | grep -q "^$tool " || pipx install "$tool" || echo "WARN: pipx install $tool failed"
  done
else
  echo "WARN: pipx missing, skipping awscli/grip"
fi

# Neovim release build into ~/.local/opt, linked from ~/.local/bin.
if [ "${SKIP_NEOVIM:-0}" != "1" ]; then
  NVIM_DIR="$HOME/.local/opt/nvim-$NEOVIM_VERSION"
  if [ ! -x "$NVIM_DIR/bin/nvim" ]; then
    mkdir -p "$NVIM_DIR"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/$NEOVIM_VERSION/nvim-linux-x86_64.tar.gz" \
      | tar xz -C "$NVIM_DIR" --strip-components=1 || echo "WARN: neovim download failed"
  fi
  [ -x "$NVIM_DIR/bin/nvim" ] && ln -sfn "$NVIM_DIR/bin/nvim" "$HOME/.local/bin/nvim"
fi

# fzf — idempotent.
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-update-rc
fi

# Docker — skip inside containers / CI. Uses the distro's packages: Docker's own
# repo needed apt-key, which modern Ubuntu no longer ships.
if [ "${SKIP_DOCKER:-0}" != "1" ]; then
  if ! command -v docker >/dev/null 2>&1; then
    install_pkgs "docker.io docker-compose-v2|docker-compose-plugin"
  fi
  $SUDO usermod -aG docker "$USER" || echo "WARN: could not add $USER to docker group"
fi

# rbenv + ruby-build.
if [ "${SKIP_RBENV:-0}" != "1" ]; then
  RBENV_BUILD_DEPS="autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev libgdbm-dev libgmp-dev ruby-dev"
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
grep -q '.apps/z/z.sh' "$HOME/.zshrc" || echo '. ~/.apps/z/z.sh' >> "$HOME/.zshrc"

# Google Chrome — desktop / Cypress only. The .deb sets up its own signed repo.
if [ "${SKIP_CHROME:-0}" != "1" ] && ! command -v google-chrome >/dev/null 2>&1; then
  TMP_DEB="$(mktemp --suffix=.deb)"
  if wget -q -O "$TMP_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
    chmod 644 "$TMP_DEB"
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
  git config --global init.defaultBranch main
fi

# nvm + Node LTS + global npm packages. Installing an nvm Node first means npm -g
# writes to ~/.nvm rather than failing on the root-owned system prefix.
if [ "${SKIP_NVM:-0}" != "1" ]; then
  if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
  fi
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    grep -q 'NVM_DIR/nvm.sh' "$rc" || cat >> "$rc" <<'NVM'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
NVM
  done
  if command -v nvm >/dev/null 2>&1; then
    nvm install --lts && nvm alias default 'lts/*' >/dev/null
    npm install -g typescript @fsouza/prettierd || echo "WARN: global npm installs failed"
  else
    echo "WARN: nvm not available, skipping Node install"
  fi
fi

# zsh as login shell.
if [ "${SKIP_CHSH:-0}" != "1" ] && command -v zsh >/dev/null 2>&1; then
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    $SUDO chsh -s "$(command -v zsh)" "$USER" || echo "WARN: chsh failed"
  fi
fi
