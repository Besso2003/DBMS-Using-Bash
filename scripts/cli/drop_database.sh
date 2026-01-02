#!/bin/bash

# =========================
# Drop Database (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

DB_NAME="$1"
DB_BASE_PATH="databases"
DB_PATH="$DB_BASE_PATH/$DB_NAME"

# Check database name
if [ -z "$DB_NAME" ]; then
    read -p "Enter database name to drop: " DB_NAME
    DB_PATH="$DB_BASE_PATH/$DB_NAME"
fi

# Check database exists
if [ ! -d "$DB_PATH" ]; then
    echo -e "${RED}Error: Database '$DB_NAME' does not exist.${RESET}"
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

    if [ "$confirm" = "$DB_NAME" ]; then
        if rm -rf -- "$DB_PATH"; then
            echo -e "${GREEN}Database '$DB_NAME' deleted successfully.${RESET}"
            exit 0
        else
            echo -e "${RED}Error: Failed to delete database '$DB_NAME'.${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Names do not match. Type the database name to confirm, or CANCEL to abort.${RESET}"
    fi
done
