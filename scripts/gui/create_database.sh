#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

while true; do
    DB_NAME=$(dialog --clear \
        --title "Create Database" \
        --inputbox "Enter database name:" 10 50 \
        2>&1 >/dev/tty)


    # Handle Cancel / Esc
    if [ $? -ne 0 ]; then
        dialog --title "Cancelled" --msgbox "Operation cancelled." 8 40
        clear
        exit 0
    fi

    # Trim spaces
    DB_NAME=$(echo "$DB_NAME" | xargs)

    # Check if input is empty
    if [ -z "$DB_NAME" ]; then
        dialog --title "Error" --msgbox \
            "Database name is required." 8 50
        continue
    fi

    # Validate characters
    if [[ ! "$DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
        dialog --title "Error" --msgbox \
            "Database name can only contain letters, numbers, and underscores." 9 60
        continue
    fi

    DB_PATH="databases/$DB_NAME"

    # Check if database already exists
    if [ -d "$DB_PATH" ]; then
        dialog --title "Error" --msgbox \
            "Database '$DB_NAME' already exists!" 8 50
        continue
    fi

    # All checks passed, create database folder
    mkdir -p "$DB_PATH"
    if [ $? -eq 0 ]; then
        dialog --title "Success" --msgbox \
            "Database '$DB_NAME' created successfully." 8 50
        clear
        exit 0
    else
        dialog --title "Error" --msgbox \
            "Failed to create database." 8 40
        clear
        exit 1
    fi
done
