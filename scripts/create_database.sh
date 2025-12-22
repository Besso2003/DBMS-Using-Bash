#!/bin/bash

db_name="$1"
db_path="databases/$db_name"

if [ -z "$db_name" ]; then
   echo "Error: Database name is required."
   exit 1
fi

if [ -d "$db_path" ]; then
   echo "Error: Database '$db_name' already exists!"
   exit 1
fi

mkdir -p "$db_path"
if [ $? -eq 0 ]; then
   echo "Database '$db_name' created successfully."
else
   echo "Error: Failed to create database."
   exit 1
fi
