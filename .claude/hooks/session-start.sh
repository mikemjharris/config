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
if rbenv install "$RUBY_VERSION"; then
  echo "✓ Ruby $RUBY_VERSION installed successfully"
else
  echo "✗ ERROR: Failed to install Ruby $RUBY_VERSION"
  exit 1
fi
echo ""

# Set as global version
echo "=== Setting Global Ruby Version ==="
rbenv global "$RUBY_VERSION"
echo "✓ Set Ruby $RUBY_VERSION as global"
echo ""

# Rehash rbenv shims
echo "=== Rehashing rbenv Shims ==="
rbenv rehash
echo "✓ rbenv shims rehashed"
echo ""

# Verify installation
echo "=== Verifying Installation ==="
if ruby --version | grep -q "$RUBY_VERSION"; then
  echo "✓ Ruby installation verified:"
  ruby --version
  echo ""
  echo "✓ Gem version:"
  gem --version
  echo ""
  echo "=========================================="
  echo "Ruby Installation Complete!"
  echo "=========================================="
  exit 0
else
  echo "✗ ERROR: Ruby $RUBY_VERSION not available after installation"
  echo "Current ruby version:"
  ruby --version || echo "(ruby command not found)"
  exit 1
fi
