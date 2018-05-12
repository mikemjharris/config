#!/bin/bash

echo "Installing homebrew (mac package manager)"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Brew installing various dependencies"
brew update
brew install nginx --with-passenger passenger wget tree openssh redis docker openssl ffmpeg  imagemagick htop postgres tmux vim jq rbenv the_silver_searcher ack nvm fzf mysql v8 elasticsearch telnet mosh

# This is required for my tmux conf setup to allow things like pbcopy / paste to work with tmux
# https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
brew install reattach-to-user-namespace

# use brew cask for install applications https://caskroom.github.io/ 
brew cask install gimp slack docker sequel-pro java 

# https://github.com/rbenv/rbenv#homebrew-on-macos
# installing rbenv needs this added to specific rc file 
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

echo 'export NVM_DIR=~/.nvm' >> ~/.zshrc
echo 'source $(brew --prefix nvm)/nvm.sh' >> ~/.zshrc

# instlal fzf - fuzzry line completion
$(brew --prefix)/opt/fzf/install

source ~/.zshrc

