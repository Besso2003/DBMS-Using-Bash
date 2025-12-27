#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"

clear
echo -e "${CYAN}===== INSERT INTO TABLE =====${RESET}"


# Function: Validate input
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                echo -e "${RED}Invalid integer. Try again.${RESET}"
                continue
            fi
        else
            if [ -z "$value" ]; then
                echo -e "${RED}Value cannot be empty. Try again.${RESET}"
                continue
            fi
        fi

        echo "$value"
        return
    done
}

# Get Table Name
while true; do
    read -p "Enter Table Name: " table_name
    meta_file="$tables_path/$table_name.meta"
    data_file="$tables_path/$table_name.db"

    if [ -z "$table_name" ]; then
        echo -e "${RED}Error:${RESET} Table name cannot be empty."
    elif [ ! -f "$meta_file" ]; then
        echo -e "${RED}Error:${RESET} Table '$table_name' does not exist."
    elif [ ! -f "$data_file" ]; then
        echo -e "${RED}Error:${RESET} Data file for table '$table_name' does not exist."
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

echo -e "\n${YELLOW}Enter values for the new row:${RESET}"

# Read row values with validation
for ((i=0; i<columns; i++)); do
    while true; do
        value=$(get_valid_input "Enter ${col_names[i]} (${col_types[i]}): " "${col_types[i]}")

        # Primary Key uniqueness validation
        if [ $((i+1)) -eq "$pk" ]; then
            if cut -d: -f"$pk" "$data_file" | grep -qx "$value"; then
                echo -e "${RED}Duplicate primary key. Enter a unique value.${RESET}"
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
echo -e "${GREEN}Row inserted successfully into table '$table_name'.${RESET}"

read -p $'\nPress Enter to return to Table Menu...'
clear
