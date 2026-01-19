#!/bin/bash
# Hook to install Ruby 3.4.4 using rbenv
# Only runs in Claude Code web instances

set -e

# Setup logging
LOG_FILE="$HOME/.claude-hooks.log"
RUBY_VERSION="3.4.4"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== SessionStart Hook: install-ruby.sh ==="
log "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-'(not set)'}"
log "CLAUDE_PROJECT_DIR: ${CLAUDE_PROJECT_DIR:-'(not set)'}"

# Only run in web environment
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  log "✓ Skipping Ruby installation - not in web environment"
  exit 0
fi

log "Running in Claude Code web instance - checking Ruby setup..."

# Check if rbenv is installed
if ! command -v rbenv &> /dev/null; then
  log "ERROR: rbenv not found. Please install rbenv first."
  exit 1
fi

# Check if ruby-build is installed
if [ ! -d "$(rbenv root)/plugins/ruby-build" ]; then
  log "ruby-build not found, installing..."
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)/plugins/ruby-build" 2>&1 | tee -a "$LOG_FILE"
  log "✓ ruby-build installed"
fi

# Update ruby-build to get latest Ruby definitions
log "Updating ruby-build to get latest Ruby definitions..."
if [ -d "$(rbenv root)/plugins/ruby-build" ]; then
  cd "$(rbenv root)/plugins/ruby-build" && git pull 2>&1 | tee -a "$LOG_FILE"
  log "✓ ruby-build updated"
else
  log "ERROR: ruby-build plugin still not found after installation attempt"
  exit 1
fi

# Check if target Ruby version is already installed
if rbenv versions 2>/dev/null | grep -q "$RUBY_VERSION"; then
  log "✓ Ruby $RUBY_VERSION is already installed via rbenv"
  rbenv global "$RUBY_VERSION"
  log "✓ Set Ruby $RUBY_VERSION as global version"
  ruby --version | tee -a "$LOG_FILE"
  log "=== Hook completed successfully ==="
  exit 0
fi

log "Installing Ruby $RUBY_VERSION via rbenv..."
if rbenv install "$RUBY_VERSION" 2>&1 | tee -a "$LOG_FILE"; then
  log "✓ Ruby $RUBY_VERSION installed successfully"
else
  log "ERROR: Failed to install Ruby $RUBY_VERSION"
  log "Available versions:"
  rbenv install --list 2>&1 | grep "^\s*3\.4\." | tee -a "$LOG_FILE"
  exit 1
fi

log "Setting Ruby $RUBY_VERSION as global version..."
rbenv global "$RUBY_VERSION"

log "Rehashing rbenv shims..."
rbenv rehash

log "✓ Ruby installation complete!"
ruby --version | tee -a "$LOG_FILE"
log "=== Hook completed successfully ==="

exit 0
