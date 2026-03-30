#!/bin/bash

# Read JSON input
input=$(cat)

# Extract current directory from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Get basename of current directory
dir_name=$(basename "$current_dir")

# Get git branch and status (skip optional locks for performance)
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false symbolic-ref --short HEAD 2>/dev/null || git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
    
    # Check if repo is dirty (skip optional locks)
    if ! git -C "$current_dir" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false diff --quiet 2>/dev/null || ! git -C "$current_dir" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false diff --cached --quiet 2>/dev/null; then
        git_status=" git:($branch) ✗"
    else
        git_status=" git:($branch)"
    fi
else
    git_status=""
fi

# Determine label based on CLAUDE_CONFIG_DIR
if [[ "$CLAUDE_CONFIG_DIR" == *"claude-sw"* ]]; then
    label="SW-CLAUDE"
elif [[ "$CLAUDE_CONFIG_DIR" == *"claude-api"* ]]; then
    label="API-CLAUDE"
else
    label="CLAUDE"
fi

# Output prompt in robbyrussell style (colors will be dimmed in status line)
printf "\033[1;32m➜\033[0m  \033[33m[%s]\033[0m \033[36m%s\033[0m%s" "$label" "$dir_name" "$git_status"
