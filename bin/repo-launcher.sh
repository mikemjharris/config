#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/repos.conf"

# Check if repos.conf exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: $CONFIG_FILE not found"
  echo "Please copy repos.conf.example to repos.conf and customize it"
  exit 1
fi

# Read repos from config file (skip comments and empty lines)
declare -a repos=()
while IFS= read -r line; do
  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
  repos+=("$line")
done < "$CONFIG_FILE"

# Colors for better UI
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RESET="\033[0m"

# Display the menu
echo -e "${BOLD}${BLUE}═══════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}          Repo Launcher${RESET}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════${RESET}"
echo ""

index=1
for repo in "${repos[@]}"; do
  name=$(echo "$repo" | cut -d'|' -f1)
  echo -e "  ${BOLD}${index}${RESET}. $name"
  ((index++))
done

echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════${RESET}"
echo -e "  Press number to open in GitHub"
echo -e "  Press ${BOLD}q${RESET} to quit"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════${RESET}"
echo ""
echo -n "Select: "

# Read single character input
read -n 1 choice
echo ""

# Handle quit
if [[ "$choice" == "q" ]]; then
  exit 0
fi

# Validate input is a number
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  echo "Invalid selection"
  exit 1
fi

# Get the selected repo (arrays are 0-indexed)
selected_index=$((choice - 1))

if [[ $selected_index -lt 0 || $selected_index -ge ${#repos[@]} ]]; then
  echo "Invalid selection"
  exit 1
fi

selected_repo="${repos[$selected_index]}"
name=$(echo "$selected_repo" | cut -d'|' -f1)
url=$(echo "$selected_repo" | cut -d'|' -f2)

echo "Opening $name in browser..."
open "$url"
