#!/bin/bash

# Create a PR with intelligent base branch detection and automated review agents
#
# This script:
# 1. Analyzes git history to suggest the best base branch
# 2. Prompts for PR title and body (like gh pr create)
# 3. Creates the PR
# 4. Launches Claude review agents to check the PR
#
# Usage:
#   ./scripts/create-pr-with-review.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the current branch
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
    log_error "Not on a branch. Please checkout a branch first."
    exit 1
fi

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    log_error "Cannot create PR from main/master branch."
    exit 1
fi

log_info "Current branch: $CURRENT_BRANCH"
echo ""

# Function to detect potential base branches
detect_base_branch() {
    log_info "Analyzing git history to suggest base branch..."

    # Get the default branch (usually main or master)
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    # Find branches with open PRs
    BRANCHES_WITH_PRS=$(gh pr list --json headRefName,baseRefName --jq '.[] | .baseRefName' 2>/dev/null | sort -u || echo "")

    # Find the commit where this branch diverged from others
    MERGE_BASE_MAIN=$(git merge-base "$CURRENT_BRANCH" "origin/$DEFAULT_BRANCH" 2>/dev/null || echo "")

    # Check if current branch was created from a feature branch
    # Look at reflog to see where branch was created
    BRANCH_CREATED_FROM=$(git reflog show --no-abbrev "$CURRENT_BRANCH" 2>/dev/null | \
        grep -E "branch: Created from" | \
        tail -1 | \
        sed -n 's/.*Created from \(.*\)/\1/p' || echo "")

    # Get branches that contain the current branch's base commit
    if [ -n "$MERGE_BASE_MAIN" ]; then
        CONTAINING_BRANCHES=$(git branch -r --contains "$MERGE_BASE_MAIN" 2>/dev/null | \
            grep -v "HEAD" | \
            sed 's/origin\///' | \
            tr -d ' ' || echo "")
    fi

    # Prioritize suggestions
    SUGGESTED_BASE=""

    # Check if there's a branch with PR that contains our merge base
    for branch in $BRANCHES_WITH_PRS; do
        if echo "$CONTAINING_BRANCHES" | grep -q "^$branch$"; then
            SUGGESTED_BASE="$branch"
            log_info "Found branch with open PR: $branch"
            break
        fi
    done

    # If no PR branch found, check if created from a feature branch
    if [ -z "$SUGGESTED_BASE" ] && [ -n "$BRANCH_CREATED_FROM" ] && [ "$BRANCH_CREATED_FROM" != "$DEFAULT_BRANCH" ]; then
        SUGGESTED_BASE="$BRANCH_CREATED_FROM"
        log_info "Branch was created from: $BRANCH_CREATED_FROM"
    fi

    # Default to main if nothing else found
    if [ -z "$SUGGESTED_BASE" ]; then
        SUGGESTED_BASE="$DEFAULT_BRANCH"
    fi

    echo "$SUGGESTED_BASE"
}

# Detect suggested base branch
SUGGESTED_BASE=$(detect_base_branch)
echo ""

# Prompt for base branch
log_info "Suggested base branch: $SUGGESTED_BASE"
read -p "$(echo -e ${BLUE}?${NC}) Enter base branch (press Enter for '$SUGGESTED_BASE'): " BASE_BRANCH
BASE_BRANCH=${BASE_BRANCH:-$SUGGESTED_BASE}
echo ""

# Show what will be in the PR
log_info "Commits that will be in the PR:"
git log --oneline "origin/$BASE_BRANCH..$CURRENT_BRANCH" 2>/dev/null || {
    log_warning "Could not compare with origin/$BASE_BRANCH. Branch may not exist remotely."
    log_info "Commits in $CURRENT_BRANCH:"
    git log --oneline "$BASE_BRANCH..$CURRENT_BRANCH" 2>/dev/null || git log --oneline -10
}
echo ""

# Prompt for PR title
log_info "Enter PR title:"
read -p "$(echo -e ${BLUE}?${NC}) Title: " PR_TITLE

if [ -z "$PR_TITLE" ]; then
    log_error "PR title is required"
    exit 1
fi
echo ""

# Prompt for PR body
log_info "Enter PR body (press Ctrl+D when done):"
echo -e "${BLUE}?${NC} Body:"
PR_BODY=$(cat)
echo ""

# Confirm PR creation
log_warning "Ready to create PR:"
echo "  Base: $BASE_BRANCH"
echo "  Head: $CURRENT_BRANCH"
echo "  Title: $PR_TITLE"
echo ""
read -p "$(echo -e ${YELLOW}?${NC}) Create PR? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    exit 0
fi
echo ""

# Create the PR
log_info "Creating PR..."
PR_URL=$(gh pr create \
    --base "$BASE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    2>&1)

if [ $? -ne 0 ]; then
    log_error "Failed to create PR"
    echo "$PR_URL"
    exit 1
fi

log_success "PR created: $PR_URL"
echo ""

# Extract PR number from URL
PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')

# Ask if user wants to run automated review agents
echo ""
read -p "$(echo -e ${YELLOW}?${NC}) Run automated Claude review agents? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Launching Claude review agents..."
    echo ""

    # Get the directory of this script
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Run the agent review script
    "$SCRIPT_DIR/run-pr-agent-review.sh" "$PR_NUMBER" all

else
    log_info "Skipping automated review."
    echo ""
    log_info "You can run reviews later with:"
    echo "  ./scripts/run-pr-agent-review.sh $PR_NUMBER"
fi

echo ""
log_success "Done! 🎉"
log_info "View PR: $PR_URL"
