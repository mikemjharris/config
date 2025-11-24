#!/bin/bash

echo "install plug for local plugins. run - :PlugInstall"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "install zsh shell"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "symlinks .tmux.conf and .vimrc along with others to your directory so that updates are easy to setup"
ln -s $(pwd)/conf/.tmux.conf  ~/.tmux.conf
ln -s $(pwd)/conf/.vimrc ~/.vimrc
ln -s $(pwd)/conf/.bash_aliases  ~/.bash_aliases
ln -s $(pwd)/bin/latest-branches.sh  ~/latest-branches.sh

echo "Linking in vim templates"
ln -s $(pwd)/conf/vim-templates ~/.vim/templates

echo "Setting up neovim config"
mkdir -p ~/.config/nvim
ln -s $(pwd)/conf/new-nvim-config/ ~/.config/nvim

echo "Setting up vim tmp folder"
mkdir ~/tmp

echo "Install vim plugins"
yes | vim +PlugInstall +qall
yes | nvim +PlugInstall +qall

echo "Linking in tmux init sessions"
ln -s $(pwd)/conf/tmux ~/.tmux

echo "Adding alias to zshrc"
cat $(pwd)/conf/setup_bash_aliases >> ~/.zshrc

echo "Setting up global gitignore"
git config --global core.excludesfile $(pwd)/conf/.gitignore_global

echo "Setting up auto remote"
git config --global push.autoSetupRemote true

echo "Setting up z plugin"
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z


echo "Setting up ctags config"
ln -s $(pwd)/conf/.ctags ~/.ctags

echo "Installing mermaid CLI for diagram rendering"
npm install -g @mermaid-js/mermaid-cli

echo "Setting up keyboard mappings for external keyboard (Akkon 65 key)"
ln -s $(pwd)/conf/keyboard ~/.mh_config

