#!/bin/bash

echo 'symlinks .tmux.conf and .vimrc along with others to your directory so that updates are easy to setup'

ln -s $(pwd)/../conf/.tmux.conf  ~/.tmux.conf
ln -s $(pwd)/../conf/.vimrc ~/.vimrc

