#!/bin/bash

# =========================
# Connect to Database (CLI)
# =========================

SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

# Colors
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

DB_NAME="$1"
DB_BASE_PATH="databases"
DB_PATH="$DB_BASE_PATH/$DB_NAME"

# Check database name
if [ -z "$DB_NAME" ]; then
    echo -e "${RED}Error: Database name is required.${RESET}"
    echo
    read -p "Press Enter to return to Main Menu..." dummy
    return 1 2>/dev/null || exit 1
fi

# Check database exists
if [ ! -d "$DB_PATH" ]; then
    echo -e "${RED}Error: Database '$DB_NAME' does not exist.${RESET}"
    echo
    read -p "Press Enter to return to Main Menu..." dummy
    return 1 2>/dev/null || exit 1
fi

# Ensure tables directory exists
mkdir -p "$DB_PATH/tables"

# Simulate connecting
echo
echo -e "${GREEN}Connecting to database '$DB_NAME'...${RESET}"
sleep 1
clear

# Call table menu
"$SCRIPT_DIR/table_menu.sh" "$DB_PATH" "$DB_NAME"
