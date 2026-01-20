#!/bin/bash
# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOTES_DIR="$SCRIPT_DIR/notes"
DATE=$(date +%Y-%m-%d)
NOTE_FILE="$NOTES_DIR/$DATE.md"

# Create notes directory if it doesn't exist
mkdir -p "$NOTES_DIR"

# Create note file if it doesn't exist
if [ ! -f "$NOTE_FILE" ]; then
    cat > "$NOTE_FILE" << EOF
# Notes for $DATE

## Tasks
- 

## Notes

EOF
fi

# Open in your editor
${EDITOR:-vim} "$NOTE_FILE"
