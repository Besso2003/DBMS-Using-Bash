#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"

clear
echo -e "${CYAN}===== DELETE FROM TABLE =====${RESET}"

# Function: Validate input
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            if [[ ! "$value" =~ ^[0-9]+$ ]]; then
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
        echo -e "${RED}Table name cannot be empty.${RESET}"
    elif [ ! -f "$meta_file" ]; then
        echo -e "${RED}Table '$table_name' does not exist.${RESET}"
    elif [ ! -f "$data_file" ]; then
        echo -e "${RED}Data file for table '$table_name' does not exist.${RESET}"
    else
        break
    fi
done

# Load metadata
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

# Choose deletion type
while true; do
    echo
    echo -e "${YELLOW}Delete By:${RESET}"
    echo "1) Primary Key"
    echo "2) Condition (Column = Value)"
    
    choice=$(get_valid_input "Choose an option [1-2]: " "int")

    case "$choice" in
        1)
            # Delete by Primary Key
            pk_col_name="${col_names[$((pk-1))]}"
            pk_value=$(get_valid_input "Enter value for Primary Key '$pk_col_name': " "${col_types[$((pk-1))]}")

            if awk -F: -v pk="$pk" -v val="$pk_value" '$pk == val { found=1 } END { exit !found }' "$data_file"; then
                awk -F: -v pk="$pk" -v val="$pk_value" '$pk != val { print }' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                echo -e "${GREEN}Record with Primary Key '$pk_value' deleted successfully.${RESET}"
                read -p $'\nPress Enter to return to Table Menu...'
                break
            else
                echo -e "${RED}Primary Key '$pk_value' not found. Try again.${RESET}"
            fi
            ;;
        2)
            # Delete by Condition
            echo -e "\n${YELLOW}Choose column to delete by:${RESET}"
            for ((i=0; i<${#col_names[@]}; i++)); do
                echo "$((i+1))) ${col_names[i]}"
            done

            col_num=$(get_valid_input "Enter column number: " "int")
            if [ "$col_num" -lt 1 ] || [ "$col_num" -gt "${#col_names[@]}" ]; then
                echo -e "${RED}Invalid column number. Try again.${RESET}"
                continue
            fi

            col_index="$col_num"
            col_name="${col_names[$((col_num-1))]}"
            col_type="${col_types[$((col_num-1))]}"
            col_value=$(get_valid_input "Enter value for $col_name ($col_type): " "$col_type")

            if awk -F: -v col="$col_index" -v val="$col_value" '$col == val { found=1 } END { exit !found }' "$data_file"; then
                awk -F: -v col="$col_index" -v val="$col_value" '$col != val { print }' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                echo -e "${GREEN}Records with $col_name = '$col_value' deleted successfully.${RESET}"
                read -p $'\nPress Enter to return to Table Menu...'
                break
            else
                echo -e "${RED}No matching records found. Try again.${RESET}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid option. Choose 1 or 2.${RESET}"
            ;;
    esac
done

clear