
alias gco="git checkout "
alias gfpwl="git push --force-with-lease"
alias hg="history | grep "
alias ip="ifconfig | grep -oEi 'inet\s(.*)\snetmask.*broadcast' | cut -d ' '  -f2"

function __tagdiff {                                                                
     git log --pretty=format:"%h%x09%an%x09%ad%x09%s" $1..$2 | grep "into 'master'" | sed -E "s/.*Merge branch '(.*)' into 'master'/\1/"
} 

alias tagdiff=__tagdiff

function __gb {
    ~/development/my-config/bin/latest-branches.sh
}

alias gb=__gb

function __gcb {
   git for-each-ref --sort=-committerdate refs/heads/ | sed "${1}q;d" | sed -E "s/.*refs\/heads\/(.*)/\1/g" | xargs git checkout
}
alias gcb=__gcb

function __ga {
    git add .
    git reset ecom-cms-webapp/pom.xml
    git status
}

alias ga=__ga



