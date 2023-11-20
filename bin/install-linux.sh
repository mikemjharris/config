sudo apt-get update

INSTALL_PKGS="
git 
vim-gtk3 
nvim
curl
apt-utils
zsh
mosh
nginx
wget
redis-server
docker
openssl
ffmpeg
imagemagick
tmux
vim-gnome
less
jq
rbenv
silversearcher-ag
ack-grep
elasticsearch
telnet
mysql-server
libmysqlclient-dev
mosh
python-pip
python-dev
build-essential
curl
locales
htop
memcached
libmemcached-tools
postgresql
libpd-dev
xclip
net-tools
npm
nodejs
libgtk2.0-0
libgtk-3-0
libgbm-dev
libnotify-dev
libgconf-2-4
libnss3
libxss1
libasound2
libxtst6 xauth xvfb
x11-apps
build-essential
ca-certificates
libcurl3-gnutls
libcurl4 
libcurl4-openssl-dev
"


#mysql_secure_installation

for i in $INSTALL_PKGS; do
  sudo apt-get install -y $i
done

#Install and upgrade pip for aws cli
sudo pip install --upgrade pip 
sudo pip install --upgrade virtualenv 
pip install awscli --upgrade --user
pip install grip  # https://github.com/joeyespo/grip markdown preview

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

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

# TODO - make this a bit more clevererrere and choose right shell...
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# create folder for any installed apps
mkdir ~/.apps

# install z which is used to move around directories 
git clone https://github.com/rupa/z.git ~/.apps/z
echo '. ~/.apps/z/z.sh' >> ~/.zshrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# install google chrome - useful for running cypress
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

git config --global user.email "hello@mikemjharris.com"
git config --global user.name "Mike Harris"
git config --global push.default current
git config --global core.editor "vim"
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false
git config --global core.hooksPath '~/.git-templates'

# This was useful in getting headphones working 
# https://askubuntu.com/a/1277644

# This is required for my tmux conf setup to allow things like pbcopy / paste to work with tmux


# Install Node /nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

# debug as nvm not always setup - also should setup the best node default
npm install -g typescript
npm install -g @fsouza/prettierd


