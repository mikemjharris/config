#!/bin/bash
# Claude Code Stop hook - logs responses to a JSONL file for the web UI

LOG_DIR="/tmp/claude-remote"
LOG_FILE="$LOG_DIR/responses.jsonl"

mkdir -p "$LOG_DIR"

# Read hook payload from stdin
INPUT=$(cat)

# Avoid infinite loops if a Stop hook is already active
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

LAST_MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# Only log if there's actual content
if [ -z "$LAST_MESSAGE" ]; then
  exit 0
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ID=$(uuidgen 2>/dev/null || date +%s%N)

jq -n \
  --arg id "$ID" \
  --arg ts "$TIMESTAMP" \
  --arg content "$LAST_MESSAGE" \
  '{"id": $id, "timestamp": $ts, "content": $content}' \
  >> "$LOG_FILE"

exit 0
