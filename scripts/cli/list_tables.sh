#!/bin/bash

# =========================
# List Tables (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"
TABLES_PATH="$DB_PATH/tables"

LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  AVAILABLE TABLES${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Tables list
if [ ! -d "$TABLES_PATH" ] || [ -z "$(ls -A "$TABLES_PATH"/*.meta 2>/dev/null)" ]; then
    left_text "${YELLOW}${BOLD}No tables found.${RESET}"
else
    count=1
    for meta_file in "$TABLES_PATH"/*.meta; do
        [ -f "$meta_file" ] || continue
        table_name=$(basename "$meta_file" .meta)
        printf -v num "%2d" "$count"
        left_text "${WHITE}${BOLD}$num) $table_name${RESET}"
        ((count++))
    done
fi

echo
read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
clear
