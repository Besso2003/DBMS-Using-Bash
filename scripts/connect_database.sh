#! /bin/bash

db_name="$1"
db_path="databases/$db_name"

if [ -z "$db_name" ]; then
    echo "Error: Database name is required."
    exit 1
fi

if [ ! -d "$db_path" ]; then
    echo "Error: Database '$db_name' does not exist."
    exit 1
fi

echo "Connected to Database: '$db_name'"

./table_menu.sh "$db_path"