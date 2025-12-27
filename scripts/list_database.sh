#! /bin/bash

db_dir="databases"

if [ ! -d "$db_dir" ]; then
   echo "No databases found."
   exit 0
fi

echo "Available Databases:"
ls -l "$db_dir"