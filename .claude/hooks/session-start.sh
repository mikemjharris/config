#!/usr/bin/env bash

# Log file path
LOG_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/claude.log"

# Function to log both to stdout and file
log() {
  echo "$@" | tee -a "$LOG_FILE"
}

# Error handling: catch all errors and exit gracefully
trap 'handle_error $? $LINENO' ERR

handle_error() {
  local exit_code=$1
  local line_number=$2
  log ""
  log "=========================================="
  log "⚠️  Hook encountered an error (exit code: $exit_code, line: $line_number)"
  log "Continuing session without completing hook..."
  log "=========================================="
  exit 0
}

# Main script logic wrapped in error handling
main() {
  # Initialize log file (overwrite existing)
  echo "===========================================" > "$LOG_FILE"
  echo "Session Start: $(date)" >> "$LOG_FILE"
  echo "Script: session-start.sh" >> "$LOG_FILE"
  echo "===========================================" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"

  log "hi from script"

  log "=========================================="
  log "Ruby Installation Hook Starting"
  log "=========================================="
  log ""

  # Log environment variables
  log "=== Environment Check ==="
  log "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-'(not set)'}"
  log "CLAUDE_PROJECT_DIR: ${CLAUDE_PROJECT_DIR:-'(not set)'}"
  log "PWD: $(pwd)"
  log "USER: ${USER:-'(not set)'}"
  log "HOME: ${HOME:-'(not set)'}"
  log ""

  # Only run in web environment
  log "=== Checking if running in web environment ==="
  if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
    log "✓ Skipping Ruby installation - not in web environment"
    log "=========================================="
    exit 0
  fi

  log "✓ Running in Claude Code web instance"
  log ""

  # Determine Ruby version to install
  RUBY_VERSION="3.4.4"  # Default version
  log "=== Ruby Version Detection ==="

  if [ -f ".ruby-version" ]; then
    log "Found .ruby-version file in current directory"
    RUBY_VERSION=$(cat .ruby-version | tr -d '[:space:]')
    log "Ruby version from .ruby-version: $RUBY_VERSION"
  elif [ -f "$HOME/dev/app/account/.ruby-version" ]; then
    log "Found .ruby-version in account app"
    RUBY_VERSION=$(cat "$HOME/dev/app/account/.ruby-version" | tr -d '[:space:]')
    log "Ruby version from account app: $RUBY_VERSION"
  else
    log "No .ruby-version found, using default: $RUBY_VERSION"
  fi
  log ""

  # Check if rbenv is installed
  log "=== Checking rbenv Installation ==="
  log "Running: command -v rbenv"
  if ! command -v rbenv &> /dev/null; then
    log "✗ ERROR: rbenv not found. Please install rbenv first."
    exit 1
  fi
  log "✓ rbenv found at: $(command -v rbenv)"
  log "✓ rbenv version: $(rbenv --version)"
  log ""

  # Check current Ruby versions
  log "=== Current Ruby Versions ==="
  log "Running: rbenv versions"
  rbenv versions 2>&1 | tee -a "$LOG_FILE" || log "No Ruby versions installed yet"
  log ""

  # Check if target Ruby version is already installed
  log "=== Checking if Ruby $RUBY_VERSION is already installed ==="
  if rbenv versions | grep -q "$RUBY_VERSION"; then
    log "=== Ruby Already Installed ==="
    log "✓ Ruby $RUBY_VERSION is already installed"
    log "Setting as global version..."
    log "Running: rbenv global $RUBY_VERSION"
    rbenv global "$RUBY_VERSION" 2>&1 | tee -a "$LOG_FILE"
    log "Running: rbenv rehash"
    rbenv rehash 2>&1 | tee -a "$LOG_FILE"
    log "✓ Ruby $RUBY_VERSION set as global"
    log ""
    log "=== Final Ruby Version ==="
    log "Running: ruby --version"
    ruby --version 2>&1 | tee -a "$LOG_FILE"
    log "=========================================="
    exit 0
  fi

  # Install Ruby
  log "=== Installing Ruby $RUBY_VERSION ==="
  log "This may take a few minutes..."
  log "Running: rbenv install $RUBY_VERSION"
  rbenv install "$RUBY_VERSION" 2>&1 | tee -a "$LOG_FILE"

  # Set as global version
  log ""
  log "=== Setting Ruby Version ==="
  log "Running: rbenv global $RUBY_VERSION"
  rbenv global "$RUBY_VERSION" 2>&1 | tee -a "$LOG_FILE"
  log "Running: rbenv rehash"
  rbenv rehash 2>&1 | tee -a "$LOG_FILE"
  log "✓ Ruby $RUBY_VERSION set as global"
  log ""

  # Verify installation
  log "=== Final Ruby Version ==="
  log "Running: ruby --version"
  ruby --version 2>&1 | tee -a "$LOG_FILE"
  log "=========================================="
}

# Run main function
main
