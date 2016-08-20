#!/bin/bash

T=$(git for-each-ref --sort=-committerdate --count=15 --format="ref=%(refname) %(*subject) $"  refs/heads/)
IFS=$'$' read -rd '' -a TEST <<<"$T"

LENGTH=${#TEST[@]}

for i in ${!TEST[@]}; do 
    echo $(($i + 1)) ${TEST[$i]};
done
