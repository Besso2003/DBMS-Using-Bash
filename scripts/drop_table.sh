#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"

LEFT_PAD=20

# Center text
center_text() {
    local text="$1"
    local term_width=$(tput cols)
    local padding=$(( (term_width - ${#text}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$(echo -e "$text")"
}

# Left padded text
left_text() {
    printf "%*s%s\n" "$LEFT_PAD" "" "$(echo -e "$1")"
}

left_prompt() {
    printf "%*s%s" "$LEFT_PAD" "" "$(echo -e "$1")"
}

echo

# Header (uses same style as list_tables)
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  DROP TABLE${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Validate database path
if [ -z "$db_path" ] || [ ! -d "$db_path" ]; then
    left_text "${RED}${BOLD}Error:${RESET} Database path missing or does not exist." 
    echo
    left_text "Usage: ./scripts/drop_table.sh <database_path>"
    echo
    exit 1
fi

# Check for tables
if [ ! -d "$tables_path" ] || [ -z "$(ls -A "$tables_path"/*.meta 2>/dev/null)" ]; then
    left_text "${YELLOW}${BOLD}No tables found in this database.${RESET}"
    echo
    left_prompt "Press Enter to return to Table Menu..."
    read -r
    exit 0
fi

# Show tables (brief list)
count=1
for meta_file in "$tables_path"/*.meta; do
    [ -f "$meta_file" ] || continue
    table_name=$(basename "$meta_file" .meta)
    printf -v num "%2d" "$count"
    left_text "${WHITE}${BOLD}$num) $table_name${RESET}"
    ((count++))
done

echo

# Prompt for table name to drop
while true; do
    left_prompt "${WHITE}${BOLD}Enter table name to drop: ${RESET}"
    read table_name

    if [ -z "$table_name" ]; then
        left_text "${RED}Error:${RESET} Table name cannot be empty."
        continue
    fi

    meta_file="$tables_path/$table_name.meta"
    data_file="$tables_path/$table_name.db"

    if [ ! -f "$meta_file" ]; then
        left_text "${RED}Error:${RESET} Table '$table_name' does not exist." 
        continue
    fi

    break
done

echo
left_text "${YELLOW}DANGEROUS ACTION:${RESET} This will permanently delete table '$table_name' and its data."
echo
left_text "Type the table name exactly to confirm deletion, or type CANCEL to abort."
echo

while true; do
    left_prompt "${WHITE}${BOLD}${table_name} > ${RESET}"
    read -r confirm
    confirm=$(echo "$confirm" | xargs)

    if [ "$confirm" = "CANCEL" ]; then
        echo
        left_text "${GREEN}Deletion aborted.${RESET}"
        echo
        left_prompt "Press Enter to return to Table Menu..."
        read -r
        exit 0
    fi

    if [ "$confirm" = "$table_name" ]; then
        if rm -f -- "$meta_file" "$data_file"; then
            left_text "${GREEN}Table '$table_name' deleted successfully.${RESET}"
            echo
            left_prompt "Press Enter to return to Table Menu..."
            read -r
            exit 0
        else
            left_text "${RED}Error: Failed to delete table '$table_name'.${RESET}"
            exit 1
        fi
    else
        left_text "${RED}Names do not match. Type the table name to confirm, or CANCEL to abort.${RESET}"
    fi
done
