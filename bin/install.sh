# inspired by https://gist.github.com/mislav/5706063

echo "Creating vimrc and tmux conf files"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.vimrc" -o  ~/.vimrc

curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/conf/.tmux.conf" -o  ~/.tmux.conf

# TODO - check if the script has been run.
# TODO - check to see which shell - mabe do for .zshrc
# TODO - even better would be to have aliases in a seperate file and source that.
echo "Adding alias' to bashrc"
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/alias-command-line" >> ~/.bashrc
