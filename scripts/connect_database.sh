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
    echo -e "${RED}Error: Database name is required.${RESET}"
    exit 1
fi

# Check database exists
if [ ! -d "$db_path" ]; then
    echo -e "${RED}Error: Database '$db_name' does not exist.${RESET}"
    exit 1
fi

# Create tables directory if not exists
mkdir -p "$db_path/tables"

# Simulate connecting
echo -e "${GREEN}Connecting to database '$db_name'...${RESET}"
sleep 1
clear

# Call table menu
./scripts/table_menu.sh "$db_path" "$db_name"
