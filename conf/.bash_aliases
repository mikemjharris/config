
### Alias for git 
alias gco="git checkout "

# If you are force pushing ALWAYS force push with lease
# https://developer.atlassian.com/blog/2015/04/force-with-lease/
alias gfpwl="git push --force-with-lease"


# Often I need to find which branches got merged into master between two tags.  This takes two tags and looks at the difference.
function __tagdiff {                                                                
     git log --pretty=format:"%h%x09%an%x09%ad%x09%s" $1..$2 | grep "into 'master'" | sed -E "s/.*Merge branch '(.*)' into 'master'/\1/"
} 

alias tagdiff=__tagdiff


# Checks for the latest branches - lists them in order of last updated with a number beside it
function __gb {
    ~latest-branches.sh
}

alias gb=__gb

# Checksout the nth branch listed by the gb command
function __gcb {
   git for-each-ref --sort=-committerdate refs/heads/ | sed "${1}q;d" | sed -E "s/.*refs\/heads\/(.*)/\1/g" | xargs git checkout
}

alias gcb=__gcb

# Often the pom.xml file is updated in dev to reference a front end snapshot jar.  Generally we don't want to commit this. Yes when commiting we should add only a couple of 
# files at a time but often only one or two files HAVE changed so running git add .  makes sense.  This file needs to be commited though so shouldn't be added to the .gitignore
function __ga {
    git add .
    git reset ecom-cms-webapp/pom.xml
    git status
}

alias ga=__ga


### Alias for command line
# I always look at my history
alias hg="history | grep "

# Quick way to check ip address
alias ip="ifconfig | grep -oEi 'inet\s(.*)\snetmask.*broadcast' | cut -d ' '  -f2"
