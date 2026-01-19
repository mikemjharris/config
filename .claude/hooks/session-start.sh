#!/usr/bin/env bash

set -e

echo "hi from script"

echo "=========================================="
echo "Ruby Installation Hook Starting"
echo "=========================================="
echo ""

# Log environment variables
echo "=== Environment Check ==="
echo "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-'(not set)'}"
echo "CLAUDE_PROJECT_DIR: ${CLAUDE_PROJECT_DIR:-'(not set)'}"
echo "PWD: $(pwd)"
echo "USER: ${USER:-'(not set)'}"
echo "HOME: ${HOME:-'(not set)'}"
echo ""

# Only run in web environment
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "✓ Skipping Ruby installation - not in web environment"
  echo "=========================================="
  exit 0
fi

echo "✓ Running in Claude Code web instance"
echo ""

# Determine Ruby version to install
RUBY_VERSION="3.4.4"  # Default version

if [ -f ".ruby-version" ]; then
  RUBY_VERSION=$(cat .ruby-version | tr -d '[:space:]')
  echo "=== Ruby Version Detection ==="
  echo "Found .ruby-version file: $RUBY_VERSION"
elif [ -f "$HOME/dev/app/account/.ruby-version" ]; then
  RUBY_VERSION=$(cat "$HOME/dev/app/account/.ruby-version" | tr -d '[:space:]')
  echo "=== Ruby Version Detection ==="
  echo "Found .ruby-version in account app: $RUBY_VERSION"
else
  echo "=== Ruby Version Detection ==="
  echo "No .ruby-version found, using default: $RUBY_VERSION"
fi
echo ""

