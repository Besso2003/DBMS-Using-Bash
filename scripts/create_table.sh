#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"
mkdir -p "$tables_path"

read -p "Enter Table Name: " table_name
[ -z "$table_name" ] && echo "Error: Table name cannot be empty" && exit 1

meta_file="$tables_path/$table_name.meta"
data_file="$tables_path/$table_name.db"

[ -f "$meta_file" ] && echo "Error: Table already exists" && exit 1

read -p "Enter number of columns: " cols
[[ ! "$cols" =~ ^[0-9]+$ || "$cols" -le 0 ]] && echo "Error: Invalid column count" && exit 1

col_names=()
col_types=()

for ((i=1; i<=cols; i++)); do
    read -p "Column $i name: " col_name

    [[ -z "$col_name" || " ${col_names[*]} " == *" $col_name "* ]] && \
        echo "Error: Invalid or duplicate column name" && exit 1

    read -p "Column $i datatype (int|string): " col_type
    [[ "$col_type" != "int" && "$col_type" != "string" ]] && \
        echo "Error: Invalid datatype" && exit 1

    col_names+=("$col_name")
    col_types+=("$col_type")
done

# choose PK column (by index)
echo "Columns:"
for ((i=0; i<cols; i++)); do
    echo "$((i+1))) ${col_names[i]}"
done

read -p "Choose Primary Key column number: " pk
[[ ! "$pk" =~ ^[0-9]+$ || "$pk" -lt 1 || "$pk" -gt "$cols" ]] && \
    echo "Error: Invalid PK column" && exit 1

# write metadata
{
    echo "pk=$pk"
    echo "columns=$cols"
    echo "types=$(IFS=:; echo "${col_types[*]}")"
    echo "names=$(IFS=:; echo "${col_names[*]}")"
} > "$meta_file"

touch "$data_file"

echo "Table '$table_name' created successfully"
echo "Primary Key: ${col_names[$((pk-1))]} (column $pk)"
