#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"
mkdir -p "$tables_path"

clear
echo -e "${CYAN}===== CREATE NEW TABLE =====${RESET}"

# Table Name
while true; do
    read -p "Enter Table Name: " table_name
    if [ -z "$table_name" ]; then
        echo -e "${RED}Error:${RESET} Table name cannot be empty."
    elif [ -f "$tables_path/$table_name.meta" ]; then
        echo -e "${RED}Error:${RESET} Table '$table_name' already exists."
    else
        meta_file="$tables_path/$table_name.meta"
        data_file="$tables_path/$table_name.db"
        break
    fi
done

# Number of Columns
while true; do
    read -p "Enter number of columns: " cols
    if [[ ! "$cols" =~ ^[0-9]+$ || "$cols" -le 0 ]]; then
        echo -e "${RED}Error:${RESET} Invalid column count."
    else
        break
    fi
done

col_names=()
col_types=()

# Column Names and Types
for ((i=1; i<=cols; i++)); do
    # Column Name
    while true; do
        read -p "Column $i name: " col_name
        if [ -z "$col_name" ]; then
            echo -e "${RED}Error:${RESET} Column name cannot be empty."
        elif [[ " ${col_names[*]} " == *" $col_name "* ]]; then
            echo -e "${RED}Error:${RESET} Duplicate column name."
        else
            col_names+=("$col_name")
            break
        fi
    done

    # Column Type
    while true; do
        read -p "Column $i datatype (int|string): " col_type
        if [[ "$col_type" != "int" && "$col_type" != "string" ]]; then
            echo -e "${RED}Error:${RESET} Invalid datatype. Use 'int' or 'string'."
        else
            col_types+=("$col_type")
            break
        fi
    done
done

# Choose Primary Key
echo -e "\n${YELLOW}Columns:${RESET}"
for ((i=0; i<cols; i++)); do
    echo "$((i+1))) ${col_names[i]}"
done

while true; do
    read -p "Choose Primary Key column number: " pk
    if [[ ! "$pk" =~ ^[0-9]+$ || "$pk" -lt 1 || "$pk" -gt "$cols" ]]; then
        echo -e "${RED}Error:${RESET} Invalid Primary Key column number."
    else
        break
    fi
done

# Write metadata and create data file
{
    echo "pk=$pk"
    echo "columns=$cols"
    echo "types=$(IFS=:; echo "${col_types[*]}")"
    echo "names=$(IFS=:; echo "${col_names[*]}")"
} > "$meta_file"

touch "$data_file"

echo -e "\n${GREEN}Table '$table_name' created successfully!${RESET}"
echo -e "Primary Key: ${col_names[$((pk-1))]} (column $pk)"

read -p $'\nPress Enter to return to Table Menu...'
clear
