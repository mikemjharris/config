:
### Alias for git 
alias gco="git checkout "

# If you are force pushing ALWAYS force push with lease
# https://developer.atlassian.com/blog/2015/04/force-with-lease/
alias gfpwl="git push --force-with-lease"

# pretty tree graph of branches
alias gl="git log --graph --decorate --pretty=oneline --abbrev-commit"

# stage hunks
alias gah="git add --patch"

# and and stash stuff to clear repo
alias gs="git add . && git stash"

# diff wit not plus and minus in front - good for copying old chunks
alias gd='git diff --color-words'

# sometimes just need to add all and ammend
alias gam="git add . && git commit --amend"

# set remote branch to local branch
alias gsb=__gsb

function __gsb {
  git branch --set-upstream-to=origin/`git rev-parse --abbrev-ref HEAD` `git rev-parse --abbrev-ref HEAD`
}

# Quick server
alias server="python -m SimpleHTTPServer 8001"

# List ssh hosts
alias hosts="cat ~/.ssh/config | grep 'Host '"

# Can't ever remember clipboard copy or paste with linux so aliasing to mac ones :(
alias pbcopy=__pbcopy

if ! command -v /mnt/c/Windows/System32/clip.exe &> /dev/null
then
  alias pbpaste=" xclip -out -sel clip"
  alias pbcopy="xclip -sel clip"
else
  # xclip doesn't work in WSL so using the mounted clip.exe instead 
  # https://github.com/microsoft/WSL/issues/1069
  alias pbpaste="powershell.exe -command 'Get-Clipboard' | tr -d '\r' | head -n -1"
  alias pbcopy="/mnt/c/Windows/System32/clip.exe"
fi

# If you have dirty json copied this makes it pretty
alias json="pbpaste | jq | pbcopy"

# we usually prefeix commit messages with the branch name.  This does that.
alias gcm=__gcm

function __gcm {
 BRANCH_NAME=`git branch | grep \* | sed -E "s/(\* )(.+)/\2/g"`
 git commit -m "$BRANCH_NAME: $1"
}


# Often I need to find which branches got merged into main between two tags.  This takes two tags and looks at the difference.
function __tagdiff {                                                                
     git log --pretty=format:"%h%x09%an%x09%ad%x09%s" $1..$2 | grep "into 'main'" | sed -E "s/.*Merge branch '(.*)' into 'main'/\1/"
} 

alias tagdiff=__tagdiff


# Checks for the latest branches - lists them in order of last updated with a number beside it
function __gb {
    ~/latest-branches.sh
}

alias gb=__gb

# Checksout the nth branch listed by the gb command
function __gcb {
   git for-each-ref --sort=-committerdate refs/heads/ | sed "${1}q;d" | sed -E "s/.*refs\/heads\/(.*)/\1/g" | xargs git checkout
}

alias gcb=__gcb

# Often the pom.xml file is updated in dev to reference a front end snapshot jar.  Generally we don't want to commit this. Yes when commiting we should add only a couple of 
# files at a time but often only one or two files HAVE changed so running git add .  makes sense.  This file needs to be commited though so shouldn't be added to the .gitignore
## OLD 
#function __ga {
#   git add .
#   git reset ecom-cms-webapp/pom.xml
#   git status
#}

# Often want to add files matching part of a pattern - here can match with part of their name.  e.g. `ga page_cont` will add page_controller
# git statu after to double check waht's been added.
function __ga {
  git add "*$1*"
  git status
}

alias ga=__ga

# Pretty tree for git log
alias lg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ce %cr)" --abbrev-commit --date=relative'


### Alias for command line
# I always look at my history
alias hg="history | grep "

# Quick way to check ip address
##alias ip="ifconfig | grep -oEi 'inet\s(.*)\snetmask.*broadcast' | cut -d ' '  -f2"


# Ruby short cuts
alias be="bundle exec "
alias st="bundle exec foreman start"

# Formatting outputs with line numvers
alias nos="awk '{print NR \":\" \$1}'"

# Create pr for current branch vs main
alias pr=__pr

function __pr {
  #  # functionality for dynamic sprint branch reading - now just go off main
  #  git fetch
  #  echo "Type branch you are coming off - most likely:"
  #  git branch -a | grep CX-sprint | sort | tail -n 1 | sed -e 's~remotes/origin/~~'
  #read branch  - used to have this when entering 
  branch="main"
  git remote -v | grep fetch | sed -e 's~.\+:\(.\+\)\..\+~https://github.com/\1/compare/'$(echo $branch)'...'$(git rev-parse --abbrev-ref HEAD)'~' | pbcopy 
}

# Use when trying to get a line from a long list.  First pipe to 'nos' to get the line number.
# e.g.  git diff main --name-only | nos 
#       git diff main --name-only | line 7
function __line {
  tail -$1 | head -n 1
}
 
alias line=__line

# Sometimes accidentally detach from tmux - want a quick way to get back in"
alias tx="tmux attach"

# I mean i never remember and it seems such an obvious alias! 
alias open="xdg-open"

# Because my fingers can never spell ~herkou~ heroku 
alias herkou="heroku"

# for plugging in remote keyboard - TODO - path is britthle - need to setup symlink properly
alias kb="~/.mh_config/setup-keyboard.sh"

# notes and todos - adds whatever is pased in to the relevant copyq tab.  
# use: note remember this
function __note {
  copyq tab notes add "$*"
}
alias note=__note

# use: todo remember to do this
function __todo {
  copyq tab todo add "$*"
}
alias todo=__todo

# Go all in on neovim - check if it exists if so let's use that
 alias vim="nvim"

# function __choose-which-vim {
#   if ! command -v nvim-nightly &> /dev/null
#   then
#     echo "Neovim nightly not installed - using vim instead"
#     /usr/bin/vim $*
#   else 
#     echo "using neovim nightly"
#     nvim-nightly $*
#   fi
# }
#
## Not an alias but sets vim config - TODO put in seperate env variable file for inclusion'
export VISUAL=vim
export EDITOR="$VISUAL"

## May as well use vim mode to edit in the terminal too :)
set editing-mode vi
## Reuduce time when hit escape to 0.1sec
export KEYTIMEOUT=1


#vim mode set esc . to be same as in emacs
bindkey -v
bindkey "\e." insert-last-word
bindkey "^[." insert-last-word
bindkey '^R' history-incremental-search-backward

# make sure vim doesn't hang on ctl s : https://unix.stackexchange.com/a/72092
stty -ixon

HISTCONTROL=ignorespace

plugins=(
  git
  zsh-z
)

# Run nvm when in new directory : https://stackoverflow.com/a/48322289
enter_directory() {
  if [[ $PWD == $PREV_PWD ]]; then
    return
  fi

  PREV_PWD=$PWD
  [[ -f ".nvmrc" ]] && nvm use
}

# Precmd is zsh hook that runs before each command. PROMPT_COMMAND is the bash hook.
precmd() {
  enter_directory
}
export PROMPT_COMMAND=enter_directory

# TODO symlink and better path
export PATH=/home/mike/working/config/local-exec:$PATH

### All for WSL and gui apps
# https://docs.microsoft.com/en-us/windows/wsl/tutorials/gui-apps
#
# set DISPLAY variable to the IP automatically assigned to WSL2
# https://shouv.medium.com/how-to-run-cypress-on-wsl2-989b83795fb6
# Wrapping this in a function as DISPALY being set seems to impact
# one of the VIM pluggins for registers
alias gui=__gui

function __gui {
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
  sudo /etc/init.d/dbus start &> /dev/null
  # https://askubuntu.com/questions/1127011/win10-linux-subsystem-libgl-error-no-matching-fbconfigs-or-visuals-found-libgl
  export LIBGL_ALWAYS_INDIRECT=1
}

# https://stackoverflow.com/questions/38558989/node-js-heap-out-of-memory
export NODE_OPTIONS=--max_old_space_size=4096

export WIN_HOME=/mnt/c/Users/mikem

alias pt=__pt

function __pt {
  for file in $(git diff-tree --no-commit-id --name-only -r HEAD); do
    npx  prettier --write "$file"
  done
}

alias docker-compose="docker compose "
