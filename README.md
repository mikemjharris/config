# Development Environment Configuration

Personal configuration repository for setting up development environments across different platforms. Contains installation scripts, dotfiles, and configurations for a modern development workflow centered around Neovim, tmux, and terminal-based tools.

## Overview

This repository supports both full local installations (with symlinked configs for easy maintenance) and one-off remote installations. The configuration is optimized for:

- **Primary environment**: Linux (Ubuntu) with Neovim as the main editor
- **Terminal workflow**: tmux for session management, modern terminal tools
- **Multiple platforms**: Native Linux, WSL, and macOS support
- **Modern editors**: Comprehensive Neovim setup with LSP, AI assistance, and productivity plugins

## Key Features

- **Neovim Configuration**: Full-featured setup with LSP, treesitter, AI coding assistants (Copilot, ChatGPT, Avante)
- **Terminal Tools**: Custom tmux sessions, keyboard layouts, shell aliases
- **Editor Support**: Configurations for Cursor IDE, VS Code, and Vim
- **AI Integration**: MCP (Model Context Protocol) configuration for Claude integration
- **Cross-platform**: Scripts for Linux, macOS, and WSL environments

## Quick Start

### Installation Scripts

**macOS** (Legacy support - install Homebrew and packages):
```bash
./bin/install-brew-packages.sh
```

**Linux** (Ubuntu/Debian - recommended):
```bash
./bin/install-linux.sh          # Core system packages
./bin/install-linux-apps.sh     # Additional applications
```

**Windows Subsystem for Linux (WSL)**:
```powershell
./bin/install-wsl.ps1           # Windows-specific setup
```


## Configuration Setup

### Local Development (Recommended)
For full development environment with symlinked configs:

```bash
# Clone the repository
git clone git@github.com:mikemjharris/config.git
cd config

# Install and symlink all configurations
./bin/local-install.sh

# Setup Neovim configuration
ln -sf $(pwd)/conf/new-nvim-setup ~/.config/nvim
```

### Remote/Temporary Setup
For quick setup on remote servers or temporary environments:

```bash
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/bin/install.sh" | bash -e
```

This creates a one-time copy of essential configs (tmux, vim, bash) without requiring Git setup.
### Windows Subsystem for Linux (WSL)
WSL setup works similarly to standard Ubuntu with these considerations:

- **Use Windows Terminal** instead of Windows Console for better font and display support
- **Theme compatibility**: Light terminal theme configured (`robbyrussell-light.zsh-theme`)
- **Run WSL-specific setup**: Use `./bin/install-wsl.ps1` for Windows-specific configurations

## Editor Configurations

### Neovim (Primary Editor)
Modern Neovim setup with comprehensive plugin ecosystem:

**Features:**
- LSP integration (Mason, nvim-lspconfig)
- AI coding assistants (Copilot, ChatGPT, Avante, Supermaven)
- File management (nvim-tree, Telescope)
- Git integration (Gitsigns)
- Syntax highlighting (Treesitter)
- Session management (Persisted)
- Modern UI (Lualine, Snacks dashboard)

**Location:** `conf/new-nvim-setup/`

### Cursor IDE
Configuration for Cursor (AI-powered VS Code fork):
```bash
ln -sf $(pwd)/conf/cursor/settings.json ~/.config/Cursor/User/settings.json
ln -sf $(pwd)/conf/cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
```

### VS Code (Legacy)
Extension and settings backup:
```bash
# Install extensions
cat ./conf/code-extensions.txt | xargs -n 1 code --install-extension

# Link settings
ln -sf $(pwd)/conf/settings.json ~/.config/Code/User/settings.json
```

## Additional Tools & Configurations

### Terminal & Shell
- **Tmux sessions**: Pre-configured sessions in `conf/tmux/`
- **Custom keyboard layouts**: Hardware keyboard configurations in `conf/keyboard/`
- **Shell aliases**: Bash aliases and functions in `conf/setup_bash_aliases`
- **Vim color schemes**: Custom themes in `conf/vim-colors/`

### AI Integration
- **MCP Configuration**: Claude AI integration setup in `mcp-config.json`
  - Linear integration for project management
  - File system operations for development workflows
- **Multiple AI Assistants**: Neovim configured with Copilot, ChatGPT, Avante, and Supermaven

### Useful Applications
These tools complement the main configuration:

- **CopyQ**: Advanced clipboard manager for Linux
- **GIMP**: Image editing and design work
- **Various terminal tools**: Installed via the Linux installation scripts

## Scripts & Utilities

- `bin/latest-branches.sh`: Git branch management utility
- `bin/pre-commit.sh`: Git pre-commit hooks
- `scripts/setup-aws.sh`: AWS development environment setup
- `local-exec/dev`: Local development execution scripts

## Development Dependencies

This repository includes Node.js dependencies for enhanced development workflows:

```bash
# Install dependencies
yarn install

# Available commands
yarn typecheck    # Type checking
yarn test         # Run tests
yarn fmt          # Format code
yarn lint         # Lint code
```

The MCP (Model Context Protocol) server integration requires these dependencies for Linear project management and development automation.

## Contributing

This is a personal configuration repository, but feel free to:
- Use any configurations that seem useful
- Suggest improvements via issues or pull requests
- Ask questions about specific configurations

The configurations are optimized for my workflow but designed to be modular and adaptable.

