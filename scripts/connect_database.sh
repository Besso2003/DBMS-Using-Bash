#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_name="$1"
db_path="databases/$db_name"

# Check database name
if [ -z "$db_name" ]; then
    echo "Error: Database name is required."
    exit 1
fi

# Check database exists
if [ ! -d "$db_path" ]; then
    echo "Error: Database '$db_name' does not exist."
    exit 1
fi

# Create tables directory if not exists
mkdir -p "$db_path/tables"

# Simulate connecting
echo -e "${CYAN}Connecting to database '$db_name'...${RESET}"
sleep 1
clear

# Call table menu
./scripts/table_menu.sh "$db_path" "$db_name"
