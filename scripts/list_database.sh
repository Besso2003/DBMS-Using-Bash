#!/bin/bash

db_dir="databases"

# Ensure databases directory exists
mkdir -p "$db_dir"

# Build message content
if [ ! -d "$db_dir" ] || [ -z "$(ls -A "$db_dir" 2>/dev/null)" ]; then
    message="No databases found."
else
    message="Available Databases:\n\n"
    count=1
    for db in "$db_dir"/*; do
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
exit 0
