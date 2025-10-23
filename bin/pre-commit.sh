#!/bin/bash

# Pre-commit hook to validate branch naming conventions
#
# To use globally (run from repo root):
#   ln -sf $(pwd)/bin/pre-commit.sh ~/.git-hooks/pre-commit
#
# Make sure git is configured to use global hooks:
#   git config --global core.hooksPath ~/.git-hooks


# These are the allowed branch names - your branch should be of format feature/mh_what-branch-does
BRANCH_NAMES="feature|feat|dependabot|tmp|chore|fix|refactor|remove|backup"

# This takes the branch name and replaces any branch that matches one of the branch names followed by a / and then any characters with TRUE
DID_BRANCH_MATCH_TYPE=$(git rev-parse --abbrev-ref HEAD | sed -E "s/($BRANCH_NAMES)\/.+/TRUE/g")


if [ $DID_BRANCH_MATCH_TYPE = "TRUE" ]
then
  echo "✓ Branch name follows naming convention"
else
  echo ""
  echo "⚠️  WARNING: Branch name doesn't follow convention"
  echo ""
  echo "Recommended format: $BRANCH_NAMES/your-branch-name"
  echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
  echo ""
  echo "Proceeding with commit anyway..."
  echo ""
fi

exit 0

