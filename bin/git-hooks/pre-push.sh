#!/bin/bash

# Pre-push hook to prevent pushing WIP commits
#
# To use globally (run from repo root):
#   ln -sf $(pwd)/bin/pre-push.sh ~/.git-hooks/pre-push
#
# Make sure git is configured to use global hooks:
#   git config --global core.hooksPath ~/.git-hooks
#
# To override this check, use: git push --no-verify

# Read the push details from stdin
while read local_ref local_sha remote_ref remote_sha
do
  # If we're deleting a branch, allow it
  if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
    continue
  fi

  # If the remote branch doesn't exist yet, check all commits
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    # Check all commits in the branch
    range="$local_sha"
  else
    # Check only new commits being pushed
    range="$remote_sha..$local_sha"
  fi

  # Search for WIP commits in the range
  wip_commits=$(git log --oneline --grep="^wip" --grep="^wip(" -E "$range")

  if [ -n "$wip_commits" ]; then
    echo ""
    echo "❌ PUSH REJECTED!"
    echo ""
    echo "You are trying to push WIP (work in progress) commits:"
    echo ""
    echo "$wip_commits"
    echo ""
    echo "Please either:"
    echo "  1. Amend or rebase to remove/squash WIP commits"
    echo "  2. Change the commit message to a proper type"
    echo "  3. Use 'git push --no-verify' to override this check"
    echo ""
    exit 1
  fi
done

exit 0
