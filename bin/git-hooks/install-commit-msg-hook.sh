#!/bin/bash

# Install script for conventional commits git hook
# This script will:
# 1. Create the global git hooks directory
# 2. Symlink the commit-msg hook
# 3. Configure git to use global hooks
# 4. Optionally configure org-specific filtering

set -e

echo ""
echo "=== Conventional Commits Hook Installer ==="
echo ""

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/commit-msg.sh"

# Check if the hook source exists
if [ ! -f "$HOOK_SOURCE" ]; then
  echo "❌ Error: commit-msg.sh not found at $HOOK_SOURCE"
  exit 1
fi

# Create global hooks directory
HOOKS_DIR="$HOME/.git-hooks"
if [ ! -d "$HOOKS_DIR" ]; then
  echo "Creating global hooks directory: $HOOKS_DIR"
  mkdir -p "$HOOKS_DIR"
fi

# Create symlink
HOOK_DEST="$HOOKS_DIR/commit-msg"
if [ -L "$HOOK_DEST" ] || [ -f "$HOOK_DEST" ]; then
  echo "Removing existing commit-msg hook..."
  rm "$HOOK_DEST"
fi

echo "Creating symlink: $HOOK_DEST -> $HOOK_SOURCE"
ln -sf "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_SOURCE"

# Configure git to use global hooks
echo "Configuring git to use global hooks..."
git config --global core.hooksPath "$HOOKS_DIR"

echo ""
echo "✓ Hook installed successfully!"
echo ""

# Ask about org filtering
echo "Do you want to run this hook on all repos, or only specific org repos?"
echo "1) All repos (default)"
echo "2) Only repos from a specific GitHub org/user"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
  2)
    echo ""
    read -p "Enter the GitHub org/user name: " org_name

    if [ -z "$org_name" ]; then
      echo "❌ No org name provided, skipping configuration"
    else
      # Determine which shell config file to use
      SHELL_CONFIG=""
      if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
      elif [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
          SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
          SHELL_CONFIG="$HOME/.bash_profile"
        fi
      fi

      if [ -z "$SHELL_CONFIG" ]; then
        echo ""
        echo "⚠️  Could not detect shell config file"
        echo "Please manually add this to your shell config:"
        echo "  export COMMIT_MSG_HOOK_ORG=$org_name"
      else
        # Check if already configured
        if grep -q "COMMIT_MSG_HOOK_ORG" "$SHELL_CONFIG"; then
          echo ""
          echo "⚠️  COMMIT_MSG_HOOK_ORG already exists in $SHELL_CONFIG"
          read -p "Do you want to update it? [y/N]: " update_choice
          if [[ $update_choice =~ ^[Yy]$ ]]; then
            # Remove old line and add new one
            sed -i.bak "/COMMIT_MSG_HOOK_ORG/d" "$SHELL_CONFIG"
            echo "export COMMIT_MSG_HOOK_ORG=$org_name" >> "$SHELL_CONFIG"
            echo "✓ Updated COMMIT_MSG_HOOK_ORG in $SHELL_CONFIG"
          fi
        else
          # Add to config file
          echo "" >> "$SHELL_CONFIG"
          echo "# Conventional commits hook - only run on $org_name repos" >> "$SHELL_CONFIG"
          echo "export COMMIT_MSG_HOOK_ORG=$org_name" >> "$SHELL_CONFIG"
          echo "✓ Added COMMIT_MSG_HOOK_ORG to $SHELL_CONFIG"
        fi

        # Set for current session
        export COMMIT_MSG_HOOK_ORG=$org_name

        echo ""
        echo "Environment variable set. You may need to restart your shell or run:"
        echo "  source $SHELL_CONFIG"
      fi
    fi
    ;;
  *)
    echo ""
    echo "✓ Hook will run on all repositories"
    ;;
esac

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The commit-msg hook will now validate your commit messages using"
echo "the Conventional Commits format: https://www.conventionalcommits.org/"
echo ""
echo "To disable the hook temporarily in a specific repo:"
echo "  COMMIT_MSG_HOOK_DISABLED=true git commit -m \"message\""
echo ""
echo "To disable the hook globally, add to your shell config:"
echo "  export COMMIT_MSG_HOOK_DISABLED=true"
echo ""
