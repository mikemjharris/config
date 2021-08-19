#/!bin/bash

# script to run pre commit to make sure branching naming convention is stuck to


# These are the allowed branch names - your branch should be of format feature/mh_what-branch-does
BRANCH_NAMES="feature|tmp|chore|fix|refactor|remove|backup"

# This takes the branch name and replaces any branch that matches one of the branch names followed by a / and then any characters with TRUE
DID_BRANCH_MATCH_TYPE=$(git rev-parse --abbrev-ref HEAD | sed -E "s/($BRANCH_NAMES)\/.+/TRUE/g")


if [ $DID_BRANCH_MATCH_TYPE = "TRUE" ]
then
  echo "Branch type matched!"
  exit 0
else
  echo ""
  echo "CODE NOT COMMITTED!!!"
  echo ""
  echo "Your branch name must statrt with one of $BRANCH_NAMES - please update before commiting!"
  echo ""
  exit 1
fi

