#!/bin/bash

echo "install pulg for local plugins. run - :PlugInstall"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "install zsh shell"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "symlinks .tmux.conf and .vimrc along with others to your directory so that updates are easy to setup"
ln -s $(pwd)/conf/.tmux.conf  ~/.tmux.conf
ln -s $(pwd)/conf/.vimrc ~/.vimrc
ln -s $(pwd)/conf/.bash_aliases  ~/.bash_aliases

echo "Linking in vim templates"
ln -s $(pwd)/conf/vim-templates ~/.vim/templates

echo "Adding alias to zshrc"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/setup_bash_aliases" >> ~/.zshrc

echo "Setting up global gitignore"
git config --global core.excludesfile $(pwd)/conf/.gitignore_global
