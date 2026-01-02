#!/bin/bash

# ==========================
# Drop Database (GUI)
# ==========================

# Use SCRIPT_DIR from selector_mode.sh or fallback
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

DB_BASE_PATH="databases"

while true; do
    db_name=$(dialog \
        --title "Drop Database" \
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

    # Dangerous warning
    dialog --clear \
        --title "DANGEROUS ACTION" \
        --yesno "This will permanently delete the database '$db_name' and all its tables.\n\nDo you want to continue?" \
        12 60

    # No / Cancel
    if [ $? -ne 0 ]; then
        exit 0
    fi

    # Delete database
    if rm -rf -- "$db_path"; then
        dialog --title "Success" \
            --msgbox "Database '$db_name' deleted successfully." 8 50
        exit 0
    else
        dialog --title "Error" \
            --msgbox "Failed to delete database '$db_name'." 8 50
        exit 1
    fi
done
