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

# Check if rbenv is installed
echo "=== Checking rbenv Installation ==="
if ! command -v rbenv &> /dev/null; then
  echo "✗ ERROR: rbenv not found. Please install rbenv first."
  exit 1
fi
echo "✓ rbenv found at: $(command -v rbenv)"
echo "✓ rbenv version: $(rbenv --version)"
echo ""

# Check current Ruby versions
echo "=== Current Ruby Versions ==="
rbenv versions || echo "No Ruby versions installed yet"
echo ""

# Check if target Ruby version is already installed
if rbenv versions | grep -q "$RUBY_VERSION"; then
  echo "=== Ruby Already Installed ==="
  echo "✓ Ruby $RUBY_VERSION is already installed"
  echo "Setting as global version..."
  rbenv global "$RUBY_VERSION"
  rbenv rehash
  echo "✓ Ruby $RUBY_VERSION set as global"
  echo ""
  echo "=== Final Ruby Version ==="
  ruby --version
  echo "=========================================="
  exit 0
fi

# Install Ruby
echo "=== Installing Ruby $RUBY_VERSION ==="
echo "This may take a few minutes..."
# rbenv install "$RUBY_VERSION"
echo "here"
if rbenv install 3.4.4; then
  echo "✓ Ruby $RUBY_VERSION installed successfully"
else
  echo "✗ ERROR: Failed to install Ruby $RUBY_VERSION"
  exit 1
fi
echo ""
