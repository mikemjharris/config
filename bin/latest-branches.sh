#!/bin/bash

#List latest 15 branches by committer date. Append a $ sign so we can split it into an array.
LATEST_BRANCHES=$(git for-each-ref --sort=-committerdate --count=15 --format="ref=%(refname) %(*subject) $"  refs/heads/)

# Parse to an array - IFS sets the word boundary to be the $ sign we appended previously
IFS=$'$' read -rd '' -a ARRAY_BRANCHES<<<"$LATEST_BRANCHES"

for i in ${!ARRAY_BRANCHES[@]}; do 
    echo $(($i + 1)) ${ARRAY_BRANCHES[$i]};
done
