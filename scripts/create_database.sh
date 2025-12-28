#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

while true; do
    read -p "Enter database name: " DB_NAME
    DB_NAME=$(echo "$DB_NAME" | xargs)  # Trim spaces

    # Check if input is empty
    if [ -z "$DB_NAME" ]; then
        echo -e "${RED}Error: Database name is required.${RESET}"
        continue
    fi

    # Validate characters
    if [[ ! "$DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}Error: Database name can only contain letters, numbers, and underscores.${RESET}"
        continue
    fi

    DB_PATH="databases/$DB_NAME"

    # Check if database already exists
    if [ -d "$DB_PATH" ]; then
        echo -e "${RED}Error: Database '$DB_NAME' already exists!${RESET}"
        continue
    fi

    # All checks passed, create database folder
    mkdir -p "$DB_PATH"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Database '$DB_NAME' created successfully.${RESET}"
        break
    else
        echo -e "${RED}Error: Failed to create database.${RESET}"
        exit 1
    fi
done
