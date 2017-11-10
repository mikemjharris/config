#!/bin/bash

echo "Brew installing various dependencies"
brew update
brew install rmagick nginx --with-passenger passenger wget tree openssh redis docker openssl ffmpeg  imagemagick htop postgres tmux vim jq

