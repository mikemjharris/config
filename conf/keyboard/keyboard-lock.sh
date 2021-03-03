#!/bin/bash

# Path to lock file
lock="/tmp/keyboard.lock"

# Lock the file (other atomic alternatives would be "ln" or "mkdir")
exec 9>"$lock"
if ! flock -n 9; then
    exit 1
fi

# Just putting in a timestamp
echo "Modified - $(date)" > $lock &
