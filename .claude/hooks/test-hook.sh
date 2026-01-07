#!/bin/bash
# Test script to verify hook environment detection

echo "=== Claude Code Hook Test ==="
echo "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-'(not set)'}"
echo "CLAUDE_PROJECT_DIR: ${CLAUDE_PROJECT_DIR:-'(not set)'}"
echo "Current directory: $(pwd)"
echo ""

if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
  echo "✓ Running in Claude Code WEB instance"
else
  echo "✗ Running in Claude Code CLI (or not in Claude Code)"
fi

echo "=== End Test ==="
