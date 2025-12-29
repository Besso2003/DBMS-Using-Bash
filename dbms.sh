#!/bin/bash

mkdir -p databases

# Source GUI helpers
source "scripts/zenity_gui.sh"

while true; do
    choice=$(gui_menu "MAIN MENU" \
        "1" "Create Database" \
        "2" "List Database" \
        "3" "Connect To Database" \
        "4" "Drop Database" \
        "5" "Exit"
    )

    # If user pressed Cancel or closed window
    if [ $? -ne 0 ]; then
        gui_info "Exit" "Exiting..."
        sleep 1
        exit 0
    fi

    case "$choice" in
        1)
            ./scripts/create_database.sh
            ;;
        2)
            ./scripts/list_database.sh
            ;;
        3)
            db_name=$(gui_input "Connect to Database" "Enter database name:")
            [ $? -ne 0 ] && continue
            ./scripts/connect_database.sh "$db_name"
            ;;
        4)
            db_name=$(gui_input "Drop Database" "Enter database name to drop:")
            [ $? -ne 0 ] && continue
            ./scripts/drop_database.sh "$db_name"
            ;;
        5)
            gui_info "Exit" "Exiting..."
            sleep 1
            exit 0
            ;;
        *)
            gui_error "Error" "Invalid choice"
            ;;
    esac
done
