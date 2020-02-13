#!/bin/bash

snap update
snap install gimp
snap install spotify
snap install elasticsearch
snap install foreman-installer
snap install foreman
snap install sequeler
snap install code --classic
snap install --edge sqlitebrowser
sudo snap install --classic heroku

sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

sudo apt-get update
# These are only really useful when using desktop
# for copyq set ubuntu keyboard preferences to set Ctrl-Shift-H to run `copyq toggle`
INSTALL_PKGS="copyq google-chrome-stable"



for i in $INSTALL_PKGS; do
  sudo apt-get install -y $i
done

