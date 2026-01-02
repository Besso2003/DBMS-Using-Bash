#!/bin/bash


while true; do

    db_name=$(dialog --title "Drop Database" --inputbox "Enter database name:" 10 50 2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0  

    db_path="databases/$db_name"
    # Validate input
    if [ -z "$db_name" ]; then
        dialog --title "Error" --msgbox "Database name is required." 10 50
        clear
        continue
    fi

    if [ ! -d "$db_path" ]; then
        dialog --title "Error" --msgbox "Database '$db_name' does not exist." 10 50
        clear
        continue
    fi


    # Dangerous warning
    dialog --clear \
        --title "DANGEROUS ACTION" \
        --yesno "This will permanently delete the database '$db_name' and all its tables.\n\nDo you want to continue?" \
        12 60

    # Cancel / No
    if [ $? -ne 0 ]; then
        clear
        exit 0
    fi




    # Delete database
    if rm -rf -- "$db_path"; then
        dialog --title "Success" \
            --msgbox "Database '$db_name' deleted successfully." \
            10 50
    else
        dialog --title "Error" \
            --msgbox "Failed to delete database '$db_name'." \
            10 50
        clear
        exit 1
    fi

    clear
    exit 0


done