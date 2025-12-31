#!/bin/bash

db_path="$1"

# Load dialog or fallback UI
if command -v dialog >/dev/null 2>&1; then
    source "scripts/dialog_ui.sh"
else
    source "scripts/ui.sh"
fi

while true; do
    # Dialog menu
    choice=$(gui_menu "TABLE MENU" \
        1 "Create Table" \
        2 "List Tables" \
        3 "Drop Table" \
        4 "Insert Into Table" \
        5 "Select From Table" \
        6 "Delete From Table" \
        7 "Update Table" \
        8 "Back to Main Menu" \
        2>&1 >/dev/tty)

    # Handle Cancel / ESC
    if [ $? -ne 0 ]; then
        exit 10
    fi

    case "$choice" in
        1)
            ./scripts/create_table.sh "$db_path"
            ;;
        2)
            ./scripts/list_tables.sh "$db_path"
            ;;
        3)
            ./scripts/drop_table.sh "$db_path"
            ;;
        4)
            ./scripts/insertion.sh "$db_path"
            ;;
        5)
            ./scripts/select.sh "$db_path"
            ;;
        6)
            ./scripts/delete_from_table.sh "$db_path"
            ;;
        7)
            ./scripts/update.sh "$db_path"
            ;;
        8)
            exit 10
            ;;
        *)
            gui_error "Error" "Invalid choice!"
            ;;
    esac
done
