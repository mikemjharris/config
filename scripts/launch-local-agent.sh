#!/bin/bash

# Launch Claude Code with local Ollama agent
#
# This script configures Claude Code to use a local Ollama instance
# instead of the Anthropic API.
#
# Prerequisites:
# - Ollama installed and running (ollama serve)
# - Model downloaded (ollama pull gpt-oss:20b)
#
# Usage:
#   ./scripts/launch-local-agent.sh [model-name]
#
# Example:
#   ./scripts/launch-local-agent.sh gpt-oss:20b

set -e

# Default model
MODEL="${1:-gpt-oss:20b}"

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
    echo "Error: Ollama is not running."
    echo "Please start Ollama with: ollama serve"
    exit 1
fi

# Check if model is available
if ! ollama list | grep -q "$MODEL"; then
    echo "Warning: Model '$MODEL' not found in Ollama."
    echo "Available models:"
    ollama list
    echo ""
    read -p "Would you like to pull the model now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ollama pull "$MODEL"
    else
        exit 1
    fi
fi

echo "Launching Claude Code with local Ollama agent..."
echo "Model: $MODEL"
echo "Ollama URL: http://localhost:11434"
echo ""

# Set environment variables and launch Claude Code
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://localhost:11434

claude --model "$MODEL"
