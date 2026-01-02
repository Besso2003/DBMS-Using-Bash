#!/bin/bash

# ==========================
# List Databases (GUI)
# ==========================

# Use SCRIPT_DIR from selector_mode.sh or fallback
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

DB_DIR="databases"

# Ensure databases directory exists
mkdir -p "$DB_DIR"

# Build message
if [ -z "$(ls -A "$DB_DIR" 2>/dev/null)" ]; then
    message="No databases found."
else
    message="Available Databases:\n\n"
    count=1
    for db in "$DB_DIR"/*; do
        [ -d "$db" ] || continue
        printf -v num "%2d" "$count"
        message+="$num) $(basename "$db")\n"
        ((count++))
    done
fi

# Show dialog
dialog --clear \
       --title "Available Databases" \
       --msgbox "$message" 20 60

clear
