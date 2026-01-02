#!/bin/bash

mkdir -p databases

# Use dialog UI if available
if command -v dialog >/dev/null 2>&1; then
    source "scripts/dialog_ui.sh"
else
    source "scripts/ui.sh"
fi

while true; do
    # Capture choice from dialog menu
    choice=$(dialog --clear --title "MAIN MENU" --menu "Choose an option:" 15 50 5 \
        1 "Create Database" \
        2 "List Database" \
        3 "Connect To Database" \
        4 "Drop Database" \
        5 "Exit" \
        2>&1 >/dev/tty)

    # Handle Cancel / Esc
    if [ $? -ne 0 ]; then
        dialog --title "Exit" --msgbox "Exiting..." 10 50
        clear
        sleep 1
        exit 0
    fi

    case "$choice" in
        1) 
            ./scripts/create_database.sh ;;
        2) 
            ./scripts/list_database.sh ;;
        3)
            ./scripts/connect_database.sh
            ;;
        4)
            ./scripts/drop_database.sh 
            ;;
        5)
            dialog --title "Exit" --msgbox "Exiting..." 10 50
            clear
            sleep 1
            exit 0
            ;;
        *)
            dialog --title "Error" --msgbox "Invalid choice" 10 50
            ;;
    esac
done