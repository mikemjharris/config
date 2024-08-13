# WIP - some commands to install things in powershell

# Let current user install scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# Install scoop - command line powershell https://scoop.sh/
iwr -useb get.scoop.sh | iex

scoop install git

git config --global user.email "hello@mikemjharris.com"
git config --global user.name "Mike Harris"
git config --global push.default current
git config --global core.editor "vim"
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false
git config --global core.hooksPath '~/.git-templates'
git config --global core.defultBranch main

# The extras bucket includes copyq
scoop add bucket extras
scoop install copyq
# Once installed run 'copyq toggle' then set preferences (i.e. don't paste on select and
# shortcut for showing/hiding (I prefer ctrl-shift h)
