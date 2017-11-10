#!/bin/bash

echo "Brew installing various dependencies"
brew update
brew install nginx --with-passenger passenger wget tree openssh redis docker openssl ffmpeg  imagemagick htop postgres tmux vim jq rbenv


# https://github.com/rbenv/rbenv#homebrew-on-macos
# installing rbenv needs this added to specific rc file 
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

source ~/.zshrc

