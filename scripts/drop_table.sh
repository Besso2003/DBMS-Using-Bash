#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[37m"
BOLD="\e[1m"
RESET="\e[0m"

# Helper dialogs
show_error() {
    dialog --title "Error" --msgbox "$1" 8 60
}

show_info() {
    dialog --title "Info" --msgbox "$1" 8 60
}

# Validate database path
if [ -z "$db_path" ] || [ ! -d "$db_path" ]; then
    show_error "Database path missing or does not exist.\nUsage: ./scripts/drop_table.sh <database_path>"
    clear
    exit 1
fi

# Check for tables
TABLES=()
for meta_file in "$tables_path"/*.meta; do
    [ -f "$meta_file" ] || continue
    TABLES+=("$(basename "$meta_file" .meta)")
done

if [ ${#TABLES[@]} -eq 0 ]; then
    show_info "No tables found in this database."
    clear
    exit 0
fi

# Select table to drop using dialog menu
MENU_ITEMS=()
for i in "${!TABLES[@]}"; do
    MENU_ITEMS+=("$((i+1))" "${TABLES[$i]}")
done

TABLE_CHOICE=$(dialog --clear \
    --title "Drop Table" \
    --menu "Select a table to drop:" 15 50 ${#TABLES[@]} "${MENU_ITEMS[@]}" 2>&1 >/dev/tty)

if [ $? -ne 0 ]; then
    dialog --title "Cancelled" --msgbox "Operation cancelled." 8 40
    clear
    exit 0
fi

TABLE_NAME="${TABLES[$((TABLE_CHOICE-1))]}"
meta_file="$tables_path/$TABLE_NAME.meta"
data_file="$tables_path/$TABLE_NAME.db"

# Confirm deletion
while true; do
    CONFIRM=$(dialog --clear \
        --title "Confirm Deletion" \
        --inputbox "DANGEROUS ACTION:\nThis will permanently delete table '$TABLE_NAME' and its data.\n\nType the table name exactly to confirm deletion, or CANCEL to abort:" 12 60 2>&1 >/dev/tty)

    if [ $? -ne 0 ]; then
        dialog --title "Cancelled" --msgbox "Deletion aborted." 8 40
        clear
        exit 0
    fi

    CONFIRM=$(echo "$CONFIRM" | xargs)

    if [ "$CONFIRM" = "CANCEL" ]; then
        show_info "Deletion aborted."
        clear
        exit 0
    fi

    if [ "$CONFIRM" = "$TABLE_NAME" ]; then
        if rm -f -- "$meta_file" "$data_file"; then
            show_info "Table '$TABLE_NAME' deleted successfully."
            clear
            exit 0
        else
            show_error "Failed to delete table '$TABLE_NAME'."
            clear
            exit 1
        fi
    else
        show_error "Names do not match. Type the table name to confirm, or CANCEL to abort."
    fi
done
