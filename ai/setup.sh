#!/bin/bash

# MJ AI Tools Setup Script
# Creates symlinks from ~/.claude/ to the config repository

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLBOX_PATH="$SCRIPT_DIR"

echo "Setting up MJ AI tools..."
echo "Source: $TOOLBOX_PATH"
echo ""

# Function to create a directory symlink
# Backs up existing directory if it contains files
create_directory_symlink() {
    local source_dir="$1"
    local target_dir="$2"
    local dir_name="$3"

    if [ ! -d "$source_dir" ]; then
        echo "  Skipping $dir_name (source directory not found)"
        return
    fi

    # If target exists and is NOT a symlink
    if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
        # Check if directory has any files
        if [ -d "$target_dir" ] && [ -n "$(ls -A "$target_dir" 2>/dev/null)" ]; then
            local timestamp=$(date +%Y%m%d-%H%M%S)
            local backup_dir="${target_dir}.backup-${timestamp}"

            echo "  Warning: $target_dir already exists with files"
            echo "  Would you like to back it up to $backup_dir? (y/n)"
            read -r response

            if [[ "$response" =~ ^[Yy]$ ]]; then
                mv "$target_dir" "$backup_dir"
                echo "  Backed up to: $backup_dir"
            else
                echo "  Removing existing $dir_name directory..."
                rm -rf "$target_dir"
            fi
        else
            # Empty directory, just remove it
            rm -rf "$target_dir"
        fi
    elif [ -L "$target_dir" ]; then
        # Remove existing symlink
        rm "$target_dir"
    fi

    # Create the symlink
    ln -s "$source_dir" "$target_dir"
    echo "  Linked entire $dir_name folder"
}

# Ensure ~/.claude/ exists
mkdir -p "$HOME/.claude"

# Setup agents
echo "Setting up agents..."
create_directory_symlink "$TOOLBOX_PATH/agents" "$HOME/.claude/agents" "agents"

# Setup commands
echo "Setting up commands..."
create_directory_symlink "$TOOLBOX_PATH/commands" "$HOME/.claude/commands" "commands"

echo ""
echo "Setup complete!"
echo ""
echo "Installed:"
echo "  - Agents:   ~/.claude/agents/   -> $TOOLBOX_PATH/agents/"
echo "  - Commands: ~/.claude/commands/  -> $TOOLBOX_PATH/commands/"
echo ""
echo "Note: Any new agents or commands added to this repo will automatically"
echo "be available without re-running setup (folders are symlinked, not files)."
echo ""
echo "To update tools later, just run: git pull"
