sudo apt-get update

INSTALL_PKGS="apt-utils zsh mosh nginx wget redis-server docker openssl ffmpeg  imagemagick tmux vim less jq rbenv silversearcher-ag ack-grep elasticsearch telnet mysql-server libmysqlclient-dev mosh python-pip python-dev build-essential curl locales"

#mysql_secure_installation

for i in $INSTALL_PKGS; do
  sudo apt-get install -y $i
done

#Install and upgrade pip for aws cli
sudo pip install --upgrade pip 
sudo pip install --upgrade virtualenv 
pip install awscli --upgrade --user

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
INSTALL_PKGS_RBENV="autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libgmp3-dev ruby-dev libmysqlclient"
for i in $INSTALL_PKGS_RBENV; do
  sudo apt-get install -y $i
done

sudo apt-get install -dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


# Install Node /nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

git config --global user.email "hello@mikemjharris.com"
git config --global user.name "Mike Harris"
git config --global push.default simple
git config --global core.editor "vim"


# Install vim plugins
yes | vim +PlugInstall +qall

# This is required for my tmux conf setup to allow things like pbcopy / paste to work with tmux
