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
LEFT_PAD=10

# Center text (for headers)
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

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                        DELETE FROM TABLE                              ${RESET}"
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
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                left_text "${RED}Invalid input. Enter a number.${RESET}" >&2
                continue
            fi
        else
            if [ -z "$value" ]; then
                left_text "${RED}Value cannot be empty.${RESET}" >&2
                continue
            fi
        fi

        # ONLY the valid value goes to stdout
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
        left_text "${RED}Table name cannot be empty.${RESET}"
    elif [ ! -f "$meta_file" ]; then
        left_text "${RED}Table '$table_name' does not exist.${RESET}"
    elif [ ! -f "$data_file" ]; then
        left_text "${RED}Data file for table '$table_name' does not exist.${RESET}"
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

# Deletion type menu
while true; do
    echo
    left_text "${YELLOW}Delete By:${RESET}"
    left_text "1) Primary Key"
    left_text "2) Condition (Column = Value)"
    left_text "3) Delete All Records"

    choice=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Choose an option [1-3]: " "int")

    if [[ "$choice" -lt 1 || "$choice" -gt 3 ]]; then
        left_text "${RED}Invalid option. Choose [1-3].${RESET}"
        continue
    fi

    case "$choice" in
        1)
            # ===== Delete by Primary Key =====
            pk_col_name="${col_names[$((pk-1))]}"
            pk_value=$(get_valid_input \
                "$(printf '%*s' $LEFT_PAD '')Enter value for Primary Key '$pk_col_name': " \
                "${col_types[$((pk-1))]}")

            if awk -F: -v pk="$pk" -v val="$pk_value" '$pk == val {found=1} END{exit !found}' "$data_file"; then
                awk -F: -v pk="$pk" -v val="$pk_value" '$pk != val' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                left_text "${GREEN}Record deleted successfully.${RESET}"
                break
            else
                left_text "${RED}Primary Key not found.${RESET}"
            fi
            ;;
        2)
            # ===== Delete by Condition =====
            left_text "${YELLOW}Choose column:${RESET}"
            for ((i=0; i<${#col_names[@]}; i++)); do
                left_text "$((i+1))) ${col_names[i]}"
            done

            col_num=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Column number: " "int")

            if [[ "$col_num" -lt 1 || "$col_num" -gt "${#col_names[@]}" ]]; then
                left_text "${RED}Invalid column number.${RESET}"
                continue
            fi

            col_name="${col_names[$((col_num-1))]}"
            col_type="${col_types[$((col_num-1))]}"
            col_value=$(get_valid_input \
                "$(printf '%*s' $LEFT_PAD '')Enter value for $col_name ($col_type): " \
                "$col_type")

            if awk -F: -v c="$col_num" -v v="$col_value" '$c == v {found=1} END{exit !found}' "$data_file"; then
                awk -F: -v c="$col_num" -v v="$col_value" '$c != v' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                left_text "${GREEN}Matching records deleted.${RESET}"
                break
            else
                left_text "${RED}No matching records found.${RESET}"
            fi
            ;;
        3)
            # ===== Delete All =====
            echo -en "$(printf '%*s' $LEFT_PAD)${YELLOW}Are you sure you want to delete ALL records in '$table_name'? [y/N]: ${RESET}"
            read confirm

            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                > "$data_file"
                echo
                left_text "${GREEN}All records deleted.${RESET}"
                echo
                read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
                break
            else
                echo
                left_text "${RED}Deletion cancelled.${RESET}"
            fi
            ;;
    esac
done

clear