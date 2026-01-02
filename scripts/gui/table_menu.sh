#!/bin/bash

# ==========================
# Table Menu (GUI)
# ==========================

db_path="$1"
db_name="$(basename "$db_path")"

# Ensure SCRIPT_DIR exists (selector-safe)
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}

# Load dialog helpers
source "$SCRIPT_DIR/dialog_ui.sh"

while true; do
    choice=$(dialog --clear \
        --title "TABLE MENU - [$db_name]" \
        --menu "Choose an option:" 18 60 10 \
        1 "Create Table" \
        2 "List Tables" \
        3 "Drop Table" \
        4 "Insert Into Table" \
        5 "Select From Table" \
        6 "Delete From Table" \
        7 "Update Table" \
        8 "Back to Main Menu" \
        2>&1 >/dev/tty)

    # ESC / Cancel → back to main menu
    if [ $? -ne 0 ]; then
        exit 10
    fi

    case "$choice" in
        1)
            "$SCRIPT_DIR/create_table.sh" "$db_path"
            ;;
        2)
            "$SCRIPT_DIR/list_tables.sh" "$db_path"
            ;;
        3)
            "$SCRIPT_DIR/drop_table.sh" "$db_path"
            ;;
        4)
            "$SCRIPT_DIR/insertion.sh" "$db_path"
            ;;
        5)
            "$SCRIPT_DIR/select.sh" "$db_path"
            ;;
        6)
            "$SCRIPT_DIR/delete_from_table.sh" "$db_path"
            ;;
        7)
            "$SCRIPT_DIR/update.sh" "$db_path"
            ;;
        8)
            exit 10
            ;;
        *)
            dialog --title "Error" --msgbox "Invalid choice!" 8 40
            ;;
    esac
done
