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
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}                    Claude Code Monitor${RESET}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo ""

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

# Sort by priority, then by idle time (descending)
IFS=$'\n' sorted_panes=($(sort -t'|' -k1,1n -k2,2rn <<< "${pane_data[*]}"))
unset IFS

# Display sorted panes
index=1
declare -a pane_ids=()

for pane_entry in "${sorted_panes[@]}"; do
  IFS='|' read -r priority idle_seconds pane_id window_name short_path status idle_time <<< "$pane_entry"
  pane_ids+=("$pane_id")

  # Extract just the pane number from pane_id (e.g., "my_dev_session:4.4" -> "pane 4")
  pane_num=$(echo "$pane_id" | cut -d. -f2)

  # Display the pane info
  echo -e "  ${BOLD}${CYAN}${index}${RESET}. ${BOLD}${window_name}${RESET} ${DIM}(pane ${pane_num})${RESET}"
  echo -e "     ${status} ${DIM}${short_path}${RESET} ${DIM}• idle ${idle_time}${RESET}"
  echo ""

  ((index++))
done

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Press ${BOLD}number${RESET} to switch to that pane"
echo -e "  Press ${BOLD}q${RESET} to quit"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -n "Select: "

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
