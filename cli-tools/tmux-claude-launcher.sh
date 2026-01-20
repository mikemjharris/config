#!/bin/bash

# Tmux session launcher for Claude Code in multiple repos
# Creates a tmux session with one window per repo, running claude in each

SESSION_NAME="claude-dev"

# Config file locations (checked in order)
CONFIG_LOCATIONS=(
  "$HOME/.tmux-claude-repos"
  "$HOME/working/config/conf/.tmux-claude-repos"
)

# Find and load config file
CONFIG_FILE=""
for location in "${CONFIG_LOCATIONS[@]}"; do
  if [ -f "$location" ]; then
    CONFIG_FILE="$location"
    break
  fi
done

if [ -z "$CONFIG_FILE" ]; then
  echo "Error: No config file found. Checked locations:"
  for location in "${CONFIG_LOCATIONS[@]}"; do
    echo "  - $location"
  done
  echo ""
  echo "Create a config file with format: window_name:path"
  echo "Example at: $HOME/working/config/conf/.tmux-claude-repos.example"
  exit 1
fi

# Load repos from config file (skip empty lines and comments)
REPOS=()
while IFS= read -r line; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  # Expand variables like $HOME
  line=$(eval echo "$line")
  REPOS+=("$line")
done < "$CONFIG_FILE"

if [ ${#REPOS[@]} -eq 0 ]; then
  echo "Error: No repositories defined in $CONFIG_FILE"
  exit 1
fi

# Check if tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session '$SESSION_NAME' already exists."
  echo "Attaching to existing session..."
  tmux attach-session -t "$SESSION_NAME"
  exit 0
fi

# Create new session with first repo
first_repo="${REPOS[0]}"
window_name="${first_repo%%:*}"
repo_path="${first_repo#*:}"

echo "Creating tmux session '$SESSION_NAME'..."
tmux new-session -d -s "$SESSION_NAME" -n "$window_name" -c "$repo_path"
tmux send-keys -t "$SESSION_NAME:$window_name" "claude" C-m

# Create additional windows for remaining repos
for i in "${!REPOS[@]}"; do
  if [ $i -eq 0 ]; then
    continue  # Skip first repo (already created)
  fi

  repo="${REPOS[$i]}"
  window_name="${repo%%:*}"
  repo_path="${repo#*:}"

  echo "Creating window '$window_name' in $repo_path..."
  tmux new-window -t "$SESSION_NAME" -n "$window_name" -c "$repo_path"
  tmux send-keys -t "$SESSION_NAME:$window_name" "claude" C-m
done

# Select first window
tmux select-window -t "$SESSION_NAME:0"

# Attach to session
echo "Attaching to session '$SESSION_NAME'..."
tmux attach-session -t "$SESSION_NAME"
