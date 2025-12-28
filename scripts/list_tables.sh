#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"



LEFT_PAD=10
source "$(dirname "$0")/ui.sh"

echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  AVAILABLE TABLES${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Tables list
if [ ! -d "$tables_path" ] || [ -z "$(ls -A "$tables_path"/*.meta 2>/dev/null)" ]; then
    left_text "${YELLOW}${BOLD}No tables found.${RESET}"
else
    count=1
    for meta_file in "$tables_path"/*.meta; do
        [ -f "$meta_file" ] || continue
        table_name=$(basename "$meta_file" .meta)
        printf -v num "%2d" "$count"
        left_text "${WHITE}${BOLD}$num) $table_name${RESET}"
        ((count++))
    done
fi

echo
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
