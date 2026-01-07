#!/bin/bash
# Hook to install Ruby 3.4.4 using rbenv
# Only runs in Claude Code web instances

set -e

# Only run in web environment
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "Skipping Ruby installation - not in web environment"
  exit 0
fi

echo "Running in Claude Code web instance - checking Ruby setup..."

# Check if rbenv is installed
if ! command -v rbenv &> /dev/null; then
  echo "ERROR: rbenv not found. Please install rbenv first."
  exit 1
fi

# Check if Ruby 3.4.4 is already installed
if rbenv versions | grep -q "3.4.4"; then
  echo "Ruby 3.4.4 is already installed via rbenv"
  rbenv global 3.4.4
  exit 0
fi

echo "Installing Ruby 3.4.4 via rbenv..."
rbenv install 3.4.4

echo "Setting Ruby 3.4.4 as global version..."
rbenv global 3.4.4

echo "Rehashing rbenv shims..."
rbenv rehash

echo "Ruby installation complete!"
ruby --version

exit 0
