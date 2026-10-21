#!/usr/bin/env bash
# Install keyd and link this repo's key remaps into /etc/keyd.
# Replaces the xkbcomp setup below, which only works on X11.
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

sudo apt-get install -y keyd
sudo mkdir -p /etc/keyd
sudo ln -sfn "$SCRIPT_DIR/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd
# Debian/Ubuntu name the binary keyd.rvaiya to avoid a clash with another package.
KEYD="$(command -v keyd || command -v keyd.rvaiya)"
sudo "$KEYD" reload
echo "keyd active. Edit $SCRIPT_DIR/keyd/default.conf then run: sudo $(basename "$KEYD") reload"
