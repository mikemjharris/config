#!/bin/bash

snap update
snap install gimp
snap install spotify
snap install elasticsearch
snap install foreman-installer
snap install foreman
snap install chrome
snap install sequeler
snap install code --classic
snap install --edge sqlitebrowser
sudo snap install --classic heroku


sudo apt-get update
# These are only really useful when using desktop
INSTALL_PKGS="gnome-shell-extensions-gpaste gpaste"

for i in $INSTALL_PKGS; do
  sudo apt-get install -y $i
done

