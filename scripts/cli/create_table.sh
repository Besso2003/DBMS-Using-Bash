#!/bin/bash

# =========================
# Create Table (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"
TABLES_PATH="$DB_PATH/tables"
mkdir -p "$TABLES_PATH"

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}==================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}CREATE NEW TABLE${RESET}"
center_text "${CYAN}${BOLD}==================================================================================================================${RESET}"
echo

# Table Name
while true; do
    left_prompt "${WHITE}${BOLD}Enter Table Name: ${RESET}"
    read table_name

    if [ -z "$table_name" ]; then
        left_text "${RED}Error:${RESET} Table name cannot be empty."
    elif [ -f "$TABLES_PATH/$table_name.meta" ]; then
        left_text "${RED}Error:${RESET} Table '$table_name' already exists."
    else
        meta_file="$TABLES_PATH/$table_name.meta"
        data_file="$TABLES_PATH/$table_name.db"
        break
    fi
done

# Number of Columns
while true; do
    left_prompt "${WHITE}${BOLD}Enter number of columns: ${RESET}"
    read cols

    if [[ ! "$cols" =~ ^[0-9]+$ || "$cols" -le 0 ]]; then
        left_text "${RED}Error:${RESET} Invalid column count."
    else
        break
    fi
done

col_names=()
col_types=()

# Column Names & Types
for ((i=1; i<=cols; i++)); do
    while true; do
        left_prompt "${WHITE}Column $i name: ${RESET}"
        read col_name

        if [ -z "$col_name" ]; then
            left_text "${RED}Error:${RESET} Column name cannot be empty."
        elif [[ " ${col_names[*]} " == *" $col_name "* ]]; then
            left_text "${RED}Error:${RESET} Duplicate column name."
        else
            col_names+=("$col_name")
            break
        fi
    done

    while true; do
        left_prompt "${WHITE}Column $i datatype (int|string): ${RESET}"
        read col_type

        if [[ "$col_type" != "int" && "$col_type" != "string" ]]; then
            left_text "${RED}Error:${RESET} Invalid datatype. Use 'int' or 'string'."
        else
            col_types+=("$col_type")
            break
        fi
    done
done

# Primary Key
echo
left_text "${YELLOW}Columns:${RESET}"
for ((i=0; i<cols; i++)); do
    left_text "$((i+1))) ${col_names[i]}"
done

while true; do
    left_prompt "${WHITE}${BOLD}Choose Primary Key column number: ${RESET}"
    read pk

    if [[ ! "$pk" =~ ^[0-9]+$ || "$pk" -lt 1 || "$pk" -gt "$cols" ]]; then
        left_text "${RED}Error:${RESET} Invalid Primary Key column number."
    else
        break
    fi
done

# Write metadata
{
    echo "pk=$pk"
    echo "columns=$cols"
    echo "types=$(IFS=:; echo "${col_types[*]}")"
    echo "names=$(IFS=:; echo "${col_names[*]}")"
} > "$meta_file"

touch "$data_file"

echo
left_text "${GREEN}Table '$table_name' created successfully!${RESET}"
left_text "Primary Key: ${col_names[$((pk-1))]} (column $pk)"

echo
left_prompt "Press Enter to return to Table Menu..."
read
clear
