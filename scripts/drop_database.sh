#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

db_name="$1"
db_path="databases/$db_name"

# Check database name
if [ -z "$db_name" ]; then
    echo -e "${RED}Error: Database name is required.${RESET}"
    exit 1
fi

# Check database exists
if [ ! -d "$db_path" ]; then
    echo -e "${RED}Error: Database '$db_name' does not exist.${RESET}"
    exit 1
fi

# Confirmation by retyping name
echo -e "${YELLOW}DANGEROUS ACTION:${RESET} This will permanently delete the database and all its tables."
echo -e "${YELLOW}Type the database name exactly to confirm deletion, or type CANCEL to abort.${RESET}"
echo

while true; do
    read -p "Confirm database name: " confirm
    confirm=$(echo "$confirm" | xargs)

    if [ "$confirm" = "CANCEL" ]; then
        echo -e "${GREEN}Deletion aborted.${RESET}"
        exit 0
    fi

    if [ "$confirm" = "$db_name" ]; then
        if rm -rf -- "$db_path"; then
            echo -e "${GREEN}Database '$db_name' deleted successfully.${RESET}"
            exit 0
        else
            echo -e "${RED}Error: Failed to delete database '$db_name'.${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Names do not match. Type the database name to confirm, or CANCEL to abort.${RESET}"
    fi
done
