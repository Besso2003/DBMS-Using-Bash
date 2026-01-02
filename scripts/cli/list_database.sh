#!/bin/bash

# =========================
# List Databases (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}
DB_DIR="databases"

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  AVAILABLE Databases${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Databases list
if [ ! -d "$DB_DIR" ] || [ -z "$(ls -A "$DB_DIR")" ]; then
    left_text "${RED}${BOLD}No databases found.${RESET}"
else
    count=1
    for db in "$DB_DIR"/*; do
        [ -d "$db" ] || continue
        printf -v num "%2d" "$count"
        left_text "${WHITE}${BOLD}$num) $(basename "$db")${RESET}"
        ((count++))
    done
fi

echo
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo
