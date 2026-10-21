#!/usr/bin/env bash
# Desktop apps — only useful on a workstation with a GUI.
# Google Chrome is installed by install-linux.sh.

set -u

sudo snap refresh
sudo snap install gimp
sudo snap install code --classic

# for copyq add 'copyq toggle' to the keyboard shortcuts in gnome (e.g. Ctrl-Shift-H)
sudo apt-get update
sudo apt-get install -y copyq
