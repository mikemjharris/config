#!/bin/bash

# Claude Code Monitor - Shows all Claude Code instances and their status

# Colors for better UI
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"
DIM="\033[2m"

# Helper function to format idle time
format_idle_time() {
  local seconds=$1
  if [[ $seconds -lt 60 ]]; then
    echo "${seconds}s"
  elif [[ $seconds -lt 3600 ]]; then
    echo "$((seconds / 60))m"
  else
    echo "$((seconds / 3600))h"
  fi
}

# Get current timestamp
current_time=$(date +%s)

# Get all panes running claude and store in array with TTY info
declare -a claude_panes=()
while IFS= read -r line; do
  [[ -n "$line" ]] && claude_panes+=("$line")
done < <(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{window_name}|#{pane_current_path}|#{pane_current_command}|#{pane_tty}" | grep "|claude|")

# Check if any Claude instances found
if [[ ${#claude_panes[@]} -eq 0 ]]; then
  echo -e "${RED}No Claude Code instances found${RESET}"
  exit 0
fi

# Display header
echo -e "${BOLD}${GREEN} Claude Code Monitor${RESET}"
echo -e "${BLUE}─────────────────────────────────${RESET}"

# Store pane data with sort keys
declare -a pane_data=()

for pane_info in "${claude_panes[@]}"; do
  IFS='|' read -r pane_id window_name pane_path pane_cmd pane_tty <<< "$pane_info"

  # Get TTY modification time (last activity)
  if [[ -n "$pane_tty" ]] && [[ -e "$pane_tty" ]]; then
    tty_mtime=$(stat -f "%m" "$pane_tty" 2>/dev/null || echo "$current_time")
  else
    tty_mtime=$current_time
  fi

  idle_seconds=$((current_time - tty_mtime))
  idle_time=$(format_idle_time $idle_seconds)

  # Capture last few lines to check status
  last_lines=$(tmux capture-pane -t "$pane_id" -p | tail -5)

  # Determine status with priority sorting
  if echo "$last_lines" | grep -q "^❯"; then
    # Waiting for user input
    status="${YELLOW}⏳ WAITING${RESET}"
    priority=1
  elif echo "$last_lines" | grep -qE "(thinking|tool|function)"; then
    # Actively processing
    status="${BLUE}⚙  PROCESSING${RESET}"
    priority=2
  elif [[ $idle_seconds -gt 300 ]]; then
    # Idle for more than 5 minutes
    status="${DIM}💤 IDLE${RESET}"
    priority=4
  else
    # Recently active
    status="${GREEN}▶  ACTIVE${RESET}"
    priority=3
  fi

  # Get short path (last 2 directories)
  short_path=$(echo "$pane_path" | awk -F'/' '{print $(NF-1)"/"$NF}')

  # Store: priority|idle_seconds|pane_id|window_name|short_path|status|idle_time
  pane_data+=("${priority}|${idle_seconds}|${pane_id}|${window_name}|${short_path}|${status}|${idle_time}")
done

# Split into recent (< 2 hours) and old (>= 2 hours), sorted by idle time within each
RECENT_THRESHOLD=7200  # 2 hours in seconds

declare -a recent_panes=()
declare -a old_panes=()

for entry in "${pane_data[@]}"; do
  idle_secs=$(echo "$entry" | cut -d'|' -f2)
  if [[ $idle_secs -lt $RECENT_THRESHOLD ]]; then
    recent_panes+=("$entry")
  else
    old_panes+=("$entry")
  fi
done

# Sort each group by priority then idle time
if [[ ${#recent_panes[@]} -gt 0 ]]; then
  IFS=$'\n' recent_panes=($(sort -t'|' -k1,1n -k2,2n <<< "${recent_panes[*]}"))
  unset IFS
fi
if [[ ${#old_panes[@]} -gt 0 ]]; then
  IFS=$'\n' old_panes=($(sort -t'|' -k2,2n <<< "${old_panes[*]}"))
  unset IFS
fi

# Display helper
index=1
declare -a pane_ids=()

display_pane() {
  local pane_entry="$1"
  IFS='|' read -r priority idle_seconds pane_id window_name short_path status idle_time <<< "$pane_entry"
  pane_ids+=("$pane_id")
  pane_num=$(echo "$pane_id" | cut -d. -f2)
  echo -e " ${BOLD}${CYAN}${index}${RESET} ${status} ${BOLD}${window_name}${RESET}${DIM}:${pane_num} ${short_path} ${idle_time}${RESET}"
  ((index++))
}

# Recent section
if [[ ${#recent_panes[@]} -gt 0 ]]; then
  echo -e " ${BOLD}${GREEN}Recent${RESET}"
  for entry in "${recent_panes[@]}"; do
    display_pane "$entry"
  done
fi

# Old section
if [[ ${#old_panes[@]} -gt 0 ]]; then
  [[ ${#recent_panes[@]} -gt 0 ]] && echo -e "${DIM}┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}"
  echo -e " ${DIM}Old${RESET}"
  for entry in "${old_panes[@]}"; do
    display_pane "$entry"
  done
fi

echo -e "${BLUE}─────────────────────────────────${RESET}"
echo -ne " ${DIM}[1-9] switch  [q] quit${RESET}: "

# Read single character input
read -n 1 choice
echo ""

# Handle quit
if [[ "$choice" == "q" || -z "$choice" ]]; then
  exit 0
fi

# Validate input is a number
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  # Invalid input - exit cleanly without error message
  exit 0
fi

# Get the selected pane (arrays are 0-indexed)
selected_index=$((choice - 1))

if [[ $selected_index -lt 0 || $selected_index -ge ${#pane_ids[@]} ]]; then
  # Out of range - exit cleanly without error message
  exit 0
fi

selected_pane="${pane_ids[$selected_index]}"

# Switch to the selected pane
tmux select-window -t "$(echo "$selected_pane" | cut -d. -f1)"
tmux select-pane -t "$selected_pane"
