#!/bin/bash

# Colors
CYAN="\033[36m"
WHITE="\033[97m"
RED="\033[31m"
BOLD="\033[1m"
RESET="\033[0m"

db_dir="databases"
LEFT_PAD=20   # <<< controls where DB list starts

# Center text (for headers)
center_text() {
    local text="$1"
    local term_width=$(tput cols)
    local padding=$(( (term_width - ${#text}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$(echo -e "$text")"
}

# Left padded text (for lists)
left_text() {
    printf "%*s%s\n" "$LEFT_PAD" "" "$(echo -e "$1")"
}

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  AVAILABLE TABLES${RESET}"
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
