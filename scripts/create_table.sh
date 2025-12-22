#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

# Ensure tables folder exists
mkdir -p "$tables_path"

read -p "Enter Table Name: " table_name

# Validate table name
if [ -z "$table_name" ]; then
    echo "Error: Table name cannot be empty!"
    return
fi

meta_file="$tables_path/$table_name.meta"
data_file="$tables_path/$table_name.data"

# Check if table exists
if [ -f "$meta_file" ]; then
    echo "Error: Table '$table_name' already exists."
    return
fi

read -p "Enter number of columns: " cols

# Validate number of columns
if ! [[ "$cols" =~ ^[0-9]+$ ]] || [ "$cols" -le 0 ]; then
    echo "Error: Invalid number of columns!"
    return
fi

echo "#column_name:datatype:constraint" > "$meta_file"

pk_defined=false

for ((i=1; i<=cols; i++)); do
    read -p "Column $i name: " col_name
    read -p "Column $i datatype (int|string): " col_type

    if [[ "$col_type" != "int" && "$col_type" != "string" ]]; then
        echo "Error: Invalid datatype!"
        rm "$meta_file"
        return
    fi

    if [ "$pk_defined" = false ]; then
        read -p "Is this column Primary Key? (y/n): " pk
        if [ "$pk" = "y" ]; then
            echo "$col_name:$col_type:PK" >> "$meta_file"
            pk_defined=true
            continue
        fi
    fi

    echo "$col_name:$col_type" >> "$meta_file"
done

touch "$data_file"

echo "Table '$table_name' created successfully."
