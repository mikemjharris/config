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

# Quick server
alias server="python -m SimpleHTTPServer 8001"

# we usually prefeix commit messages with the branch name.  This does that.
alias gcm=__gcm

function __gcm {
 BRANCH_NAME=`git branch | grep \* | sed -E "s/(\* )(.+)/\2/g"`
 git commit -m "$BRANCH_NAME: $1"
}


# Often I need to find which branches got merged into master between two tags.  This takes two tags and looks at the difference.
function __tagdiff {                                                                
     git log --pretty=format:"%h%x09%an%x09%ad%x09%s" $1..$2 | grep "into 'master'" | sed -E "s/.*Merge branch '(.*)' into 'master'/\1/"
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
  git add **$1**
  git status
}

alias ga=__ga

# Pretty tree for git log
alias lg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ce %cr)" --abbrev-commit --date=relative'


### Alias for command line
# I always look at my history
alias hg="history | grep "

# Quick way to check ip address
alias ip="ifconfig | grep -oEi 'inet\s(.*)\snetmask.*broadcast' | cut -d ' '  -f2"


# Ruby short cuts
alias be="bundle exec "
alias st="bundle exec foreman start"

# Formatting outputs with line numvers
alias nos="awk '{print NR \":\" \$1}'"

# Create pr for current branch vs master
alias pr=__pr

function __pr {
  git fetch
  echo "Type branch you are coming off - most likely:"
  git branch -a | grep CX-sprint | sort | tail -n 1 | sed -e 's~remotes/origin/~~'
  read branch
  git remote -v | grep fetch | sed -e 's~.\+:\(.\+\)\..\+~https://github.com/\1/compare/'$(echo $branch)'...'$(git rev-parse --abbrev-ref HEAD)'~' | xclip -sel clip
}

# Use when trying to get a line from a long list.  First pipe to 'nos' to get the line number.
# e.g.  git diff master --name-only | nos 
#       git diff master --name-only | line 7
function __line {
  tail -$1 | head -n 1
}
 
alias line=__line

## Not an alias but sets vim config - TODO put in seperate env variable file for inclusion'
export VISUAL=vim
export EDITOR="$VISUAL"

## May as well use vim mode to edit in the terminal too :)
set editing-mode vi

#vim mode set esc . to be same as in emacs
bindkey "\e." insert-last-word
