#!/bin/bash

db_dir="databases"

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=20
source "$(dirname "$0")/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  AVAILABLE Databases${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Databases list
if [ ! -d "$db_dir" ] || [ -z "$(ls -A "$db_dir")" ]; then
    left_text "${RED}${BOLD}No databases found.${RESET}"
else
    count=1
    for db in "$db_dir"/*; do
        [ -d "$db" ] || continue
        printf -v num "%2d" "$count"
        left_text "${WHITE}${BOLD}$num) $(basename "$db")${RESET}"
        ((count++))
    done
fi

echo
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo
