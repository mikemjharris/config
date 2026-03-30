#!/bin/bash
# Start Claude Code in a named tmux session for remote web access

SESSION="claude-remote"
LOG_DIR="/tmp/claude-remote"

# Create log directory
mkdir -p "$LOG_DIR"

# Check if session already exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already exists"
  tmux list-windows -t "$SESSION"
  exit 0
fi

# Create session with claude running inside
tmux new-session -d -s "$SESSION" -x 200 -y 50 "claude"

echo "Started tmux session '$SESSION' with claude"
echo "Log directory: $LOG_DIR"
echo ""
echo "Attach with:  tmux attach -t $SESSION"
echo "Web server:   node scripts/claude-web/server.js"
