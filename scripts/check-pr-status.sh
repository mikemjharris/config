#!/bin/bash

# Script to check PR status across multiple Skiller Whale repositories
# Shows which PRs have been approved

REPOS=(
  "skiller-whale/account"
  "skiller-whale/train"
  "skiller-whale/assessor"
)

echo "==================================="
echo "PR Status Across Repositories"
echo "==================================="
echo ""

for repo in "${REPOS[@]}"; do
  echo "📦 Repository: $repo"
  echo "-----------------------------------"
  
  # Get open PRs with review status
  prs=$(gh pr list --repo "$repo" --json number,title,author,reviewDecision,reviews,state,url --limit 100)
  
  if [ "$prs" = "[]" ]; then
    echo "  No open PRs"
    echo ""
    continue
  fi
  
  # Parse and display PRs with approval status
  echo "$prs" | jq -r '.[] | 
    "  PR #\(.number): \(.title)\n" +
    "    Author: \(.author.login)\n" +
    "    Status: \(.reviewDecision // "NO_REVIEW")\n" +
    "    URL: \(.url)\n"'
  
  echo ""
done

echo "==================================="
echo "Legend:"
echo "  APPROVED - PR has been approved"
echo "  CHANGES_REQUESTED - Changes requested"
echo "  NO_REVIEW - No reviews yet"
echo "==================================="
