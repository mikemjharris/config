#!/bin/bash

snap update
snap install gimp
snap install sequeler
snap install code --classic

sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

sudo apt-get update
# These are only really useful when using desktop
# for copyq set ubuntu keyboard preferences to set Ctrl-Shift-H to run `copyq toggle`
INSTALL_PKGS="copyq google-chrome-stable"

# for copyq add 'copyq toggle' to the keyboard shortcuts in gnome 

for i in $INSTALL_PKGS; do
  sudo apt-get install -y $i
done

