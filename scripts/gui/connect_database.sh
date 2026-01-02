#!/bin/bash

# ==========================
# Connect to Database (GUI)
# ==========================

# Use SCRIPT_DIR from selector_mode.sh or fallback
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

DB_BASE_PATH="databases"

while true; do
    db_name=$(dialog \
        --title "Connect to Database" \
        --inputbox "Enter database name:" 10 50 \
        2>&1 >/dev/tty)

    # Cancel / ESC
    if [ $? -ne 0 ]; then
        exit 0
    fi

    # Trim spaces
    db_name=$(echo "$db_name" | xargs)
    db_path="$DB_BASE_PATH/$db_name"

    # Empty name
    if [ -z "$db_name" ]; then
        dialog --title "Error" --msgbox "Database name is required." 8 50
        continue
    fi

    # Database does not exist
    if [ ! -d "$db_path" ]; then
        dialog --title "Error" --msgbox "Database '$db_name' does not exist." 8 50
        continue
    fi

    # Ensure tables directory exists
    mkdir -p "$db_path/tables"

    # Connecting message
    dialog --title "Connecting" --infobox \
        "Connecting to database '$db_name'..." 5 50
    sleep 1
    clear

    # Call GUI table menu
    "$SCRIPT_DIR/table_menu.sh" "$db_path" "$db_name"
    status=$?

    # Back to main menu
    if [ "$status" -eq 10 ]; then
        break
    fi
done
