#!/bin/bash

# ==========================
# Create Database (GUI)
# ==========================

# Use SCRIPT_DIR from selector_mode.sh or fallback
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

DB_BASE_PATH="databases"
mkdir -p "$DB_BASE_PATH"

while true; do
    DB_NAME=$(dialog --clear \
        --title "Create Database" \
        --inputbox "Enter database name:" 10 50 \
        2>&1 >/dev/tty)

    # Cancel / Esc
    if [ $? -ne 0 ]; then
        dialog --title "Cancelled" --msgbox "Operation cancelled." 8 40
        exit 0
    fi

    # Trim spaces
    DB_NAME=$(echo "$DB_NAME" | xargs)

    # Empty name
    if [ -z "$DB_NAME" ]; then
        dialog --title "Error" --msgbox \
            "Database name is required." 8 50
        continue
    fi

    # Invalid characters
    if [[ ! "$DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
        dialog --title "Error" --msgbox \
            "Database name can only contain letters, numbers, and underscores." 9 60
        continue
    fi

    DB_PATH="$DB_BASE_PATH/$DB_NAME"

    # Already exists
    if [ -d "$DB_PATH" ]; then
        dialog --title "Error" --msgbox \
            "Database '$DB_NAME' already exists!" 8 50
        continue
    fi

    # Create database
    if mkdir -p "$DB_PATH"; then
        dialog --title "Success" --msgbox \
            "Database '$DB_NAME' created successfully." 8 50
        exit 0
    else
        dialog --title "Error" --msgbox \
            "Failed to create database." 8 40
        exit 1
    fi
done
