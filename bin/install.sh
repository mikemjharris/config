# inspired by https://gist.github.com/mislav/5706063

echo "Creating vimrc and tmux conf files"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.vimrc" -o  ~/.vimrc

curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.tmux.conf" -o  ~/.tmux.conf

echo "Creating irbrc"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.irbrc" -o  ~/.irbrc

# TODO - check if the script has been run.
# TODO - check to see which shell - mabe do for .zshrc
# TODO - even better would be to have aliases in a seperate file and source that.
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.bash_aliases" >> ~/.bash_aliases

echo "Adding alias' to bashrc"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/setup_bash_aliases" >> ~/.bashrc

echo "Adding alias' to zshrc"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/setup_bash_aliases" >> ~/.zshrc
