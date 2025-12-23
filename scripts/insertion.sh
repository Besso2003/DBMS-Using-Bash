#! /bin/bash

db_path="$1"
tables_path="$db_path/tables"
 
read -p "Enter Table Name: " table_name

meta_file="$tables_path/$table_name.meta"
data_file="$tables_path/$table_name.db"

if [ ! -f "$meta_file" ]; then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

if [ ! -f "$data_file" ]; then
    echo "Error: Data file for table '$table_name' does not exist."
    exit 1
fi
# Read metadata

IFS=':' read -ra  col_names <<< "$names"
IFS=':' read -ra  col_types <<< "$types"

row=()
pk_value=""

for