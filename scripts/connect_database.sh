#!/bin/bash


while true; do
    db_name=$(dialog --title "Connect to Database" --inputbox "Enter database name:" 10 50 2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0  
    db_path="databases/$db_name"
    # Check database name
    if [ -z "$db_name" ]; then
        dialog --title "Error" --msgbox "Database name is required." 10 50
        clear
        continue
    fi

    # Check database exists
    if [ ! -d "$db_path" ]; then
        dialog --title "Error" --msgbox "Database '$db_name' does not exist." 10 50
        clear
        continue
    fi

    # Create tables directory if not exists
    mkdir -p "$db_path/tables"

    # Simulate connecting
    dialog --title "Connecting" --infobox "Connecting to database '$db_name'..." 5 50
    sleep 1
    clear

    # Call table menu
    ./scripts/table_menu.sh "$db_path" "$db_name"

done
