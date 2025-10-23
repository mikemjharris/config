#!/bin/bash

# Conventional Commits validation hook
# https://www.conventionalcommits.org/en/v1.0.0/
#
# To use globally (run from repo root):
#   ln -sf $(pwd)/bin/commit-msg.sh ~/.git-hooks/commit-msg
#
# Make sure git is configured to use global hooks:
#   git config --global core.hooksPath ~/.git-hooks

# Read the commit message from the file passed as argument
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Get just the first line (subject line)
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n 1)

# Allowed types according to conventional commits
TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

# Regex pattern for conventional commits
# Format: type(optional scope): description
# The ! for breaking changes is optional
PATTERN="^($TYPES)(\(.+\))?!?: .{1,}"

if echo "$FIRST_LINE" | grep -qE "$PATTERN"; then
  echo "✓ Commit message follows conventional commits format"
  exit 0
else
  echo ""
  echo "❌ COMMIT REJECTED!"
  echo ""
  echo "Your commit message does not follow the Conventional Commits format."
  echo ""
  echo "Expected format:"
  echo "  <type>[optional scope][!]: <description>"
  echo ""
  echo "  [optional body]"
  echo ""
  echo "  [optional footer(s)]"
  echo ""
  echo "Types: $TYPES"
  echo ""
  echo "Examples:"
  echo "  feat: add new feature"
  echo "  fix(auth): resolve login issue"
  echo "  docs: update README"
  echo "  feat!: breaking change"
  echo "  fix(api)!: breaking API change"
  echo ""
  echo "Your commit message:"
  echo "  $FIRST_LINE"
  echo ""
  echo "See https://www.conventionalcommits.org/ for more details"
  echo ""
  exit 1
fi
