sudo apt-get update

sudo apt-get install zsh mosh nginx wget redis-server docker openssl ffmpeg  imagemagick tmux vim jq rbenv silversearcher-ag ack-grep elasticsearch telnet mysql-server libmysqlclient-dev
#mysql_secure_installation

# fuzzy search /completion
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce


# Install rbenv ruby
sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libgmp3-dev ruby-dev libmysqlclient

sudo apt-get install -dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


# Install Node /nvm
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh -o install_nvm.sh
bash install_nvm.sh








# This is required for my tmux conf setup to allow things like pbcopy / paste to work with tmux
