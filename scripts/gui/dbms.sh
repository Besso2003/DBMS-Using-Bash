#!/bin/bash

# ==========================
# GUI Main Menu (Dialog)
# ==========================

# Ensure databases folder exists
mkdir -p databases

# Use SCRIPT_DIR from selector_mode.sh or fallback
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

# Source dialog helpers
source "$SCRIPT_DIR/dialog_ui.sh"

while true; do
    choice=$(dialog --clear \
        --title "MAIN MENU" \
        --menu "Choose an option:" 15 50 5 \
        1 "Create Database" \
        2 "List Databases" \
        3 "Connect To Database" \
        4 "Drop Database" \
        5 "Exit" \
        2>&1 >/dev/tty)

    # Cancel / ESC
    if [ $? -ne 0 ]; then
        dialog --title "Exit" --msgbox "Exiting..." 8 40
        clear
        exit 0
    fi

    case "$choice" in
        1)
            "$SCRIPT_DIR/create_database.sh"
            ;;
        2)
            "$SCRIPT_DIR/list_database.sh"
            ;;
        3)
            "$SCRIPT_DIR/connect_database.sh"
            ;;
        4)
            "$SCRIPT_DIR/drop_database.sh"
            ;;
        5)
            dialog --title "Exit" --msgbox "Exiting..." 8 40
            clear
            exit 0
            ;;
        *)
            dialog --title "Error" --msgbox "Invalid choice." 8 40
            ;;
    esac
done
