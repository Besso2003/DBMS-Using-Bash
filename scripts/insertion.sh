#!/bin/bash

# Colors
CYAN="\033[36m"
WHITE="\033[97m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

db_path="$1"
tables_path="$db_path/tables"
LEFT_PAD=10   # controls where the table info starts

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
center_text "${WHITE}${BOLD}                                         INSERT INTO TABLE                             ${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Function: Validate input
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                left_text "${RED}Invalid integer. Try again.${RESET}"
                continue
            fi
        else
            if [ -z "$value" ]; then
                left_text "${RED}Value cannot be empty. Try again.${RESET}"
                continue
            fi
        fi

        echo "$value"
        return
    done
}

# Get Table Name
while true; do
    read -p "$(printf '%*s' $LEFT_PAD)Enter Table Name: " table_name
    meta_file="$tables_path/$table_name.meta"
    data_file="$tables_path/$table_name.db"

    if [ -z "$table_name" ]; then
        left_text "${RED}Error:${RESET} Table name cannot be empty."
    elif [ ! -f "$meta_file" ]; then
        left_text "${RED}Error:${RESET} Table '$table_name' does not exist."
    elif [ ! -f "$data_file" ]; then
        left_text "${RED}Error:${RESET} Data file for table '$table_name' does not exist."
    else
        break
    fi
done

# Load metadata
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

row=()
pk_value=""

# Left-padded header for entering row values
left_text "${YELLOW}Enter values for the new row:${RESET}"
echo

# Read row values with validation
for ((i=0; i<columns; i++)); do
    while true; do
        value=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Enter ${col_names[i]} (${col_types[i]}): " "${col_types[i]}")

        # Primary Key uniqueness validation
        if [ $((i+1)) -eq "$pk" ]; then
            if cut -d: -f"$pk" "$data_file" | grep -qx "$value"; then
                left_text "${RED}Duplicate primary key. Enter a unique value.${RESET}"
                continue
            fi
            pk_value="$value"
        fi

        row+=("$value")
        break
    done
done

# Insert row into data file
echo "$(IFS=:; echo "${row[*]}")" >> "$data_file"
left_text "${GREEN}Row inserted successfully into table '$table_name'.${RESET}"
echo

read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
clear
