#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

read -p "Enter Table Name: " table_name

meta_file="$tables_path/$table_name.meta"
data_file="$tables_path/$table_name.db"

# Validate table existence
[ ! -f "$meta_file" ] && echo "Error: Table '$table_name' does not exist." && exit 1
[ ! -f "$data_file" ] && echo "Error: Data file for table '$table_name' does not exist." && exit 1

source "$meta_file"

# Validate metadata
[[ ! "$pk" =~ ^[0-9]+$ ]] && echo "Corrupted metadata (pk)" && exit 1
[[ ! "$columns" =~ ^[0-9]+$ ]] && echo "Corrupted metadata (columns)" && exit 1

IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

row=()
pk_value=""

# ----------------------------
# Read row values (with loops)
# ----------------------------
for ((i=0; i<columns; i++)); do
    while true; do
        read -p "Enter ${col_names[i]} (${col_types[i]}): " value

        # INT validation
        if [ "${col_types[i]}" = "int" ]; then
            [[ ! "$value" =~ ^-?[0-9]+$ ]] && \
                echo "Invalid integer. Try again." && continue
        else
            [ -z "$value" ] && \
                echo "Value cannot be empty. Try again." && continue
        fi

        # Primary Key validation
        if [ $((i+1)) -eq "$pk" ]; then
            if cut -d: -f"$pk" "$data_file" | grep -qx "$value"; then
                echo "Duplicate primary key. Enter a unique value."
                continue
            fi
            pk_value="$value"
        fi

        row+=("$value")
        break
    done
done

# Insert row
echo "$(IFS=:; echo "${row[*]}")" >> "$data_file"

echo "Row inserted successfully"
