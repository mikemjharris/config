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

