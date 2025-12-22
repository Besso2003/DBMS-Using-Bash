#! /bin/bash

db_name="$1"
db_path="databases/$db_name"

# Check database name
if [ -z "$db_name" ]; then
    echo "Error: Database name is required."
    exit 1
fi

# Check database exists
if [ ! -d "$db_path" ]; then
    echo "Error: Database '$db_name' does not exist."
    exit 1
fi

# Create tables directory if not exists
mkdir -p "$db_path/tables"


# Clear screen → NEW SCREEN
clear
echo "================================"
echo " Connected to Database: $db_name"
echo "================================"

./scripts/table_menu.sh "$db_path"