#!/bin/bash

# ==========================
# Drop Table (GUI)
# ==========================

db_path="$1"
tables_path="$db_path/tables"

SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}
source "$SCRIPT_DIR/dialog_ui.sh"

# --------------------------
# Validate database path
# --------------------------
if [ -z "$db_path" ] || [ ! -d "$db_path" ]; then
    dialog --title "Error" \
           --msgbox "Database path missing or does not exist." 8 50
    clear
    exit 1
fi

mkdir -p "$tables_path"

# --------------------------
# Collect tables
# --------------------------
TABLES=()
for meta_file in "$tables_path"/*.meta; do
    [ -f "$meta_file" ] || continue
    TABLES+=("$(basename "$meta_file" .meta)")
done

if [ ${#TABLES[@]} -eq 0 ]; then
    dialog --title "Info" \
           --msgbox "No tables found in this database." 8 50
    clear
    exit 0
fi

# --------------------------
# Select table
# --------------------------
MENU_ITEMS=()
for i in "${!TABLES[@]}"; do
    MENU_ITEMS+=("$((i+1))" "${TABLES[$i]}")
done

TABLE_CHOICE=$(dialog --clear \
    --title "Drop Table" \
    --menu "Select a table to drop:" 15 50 "${#TABLES[@]}" \
    "${MENU_ITEMS[@]}" 2>&1 >/dev/tty)

# Cancel / ESC
if [ $? -ne 0 ]; then
    dialog --title "Cancelled" --msgbox "Operation cancelled." 8 40
    clear
    exit 0
fi

TABLE_NAME="${TABLES[$((TABLE_CHOICE-1))]}"
meta_file="$tables_path/$TABLE_NAME.meta"
data_file="$tables_path/$TABLE_NAME.db"

# --------------------------
# Dangerous confirmation
# --------------------------
while true; do
    CONFIRM=$(dialog --clear \
        --title "⚠️ DANGEROUS ACTION" \
        --inputbox "This will permanently delete the table:\n\n  $TABLE_NAME\n\nType the table name exactly to confirm,\nor type CANCEL to abort:" \
        14 60 2>&1 >/dev/tty)

    # Cancel / ESC
    if [ $? -ne 0 ]; then
        dialog --title "Cancelled" --msgbox "Deletion aborted." 8 40
        clear
        exit 0
    fi

    CONFIRM=$(echo "$CONFIRM" | xargs)

    if [ "$CONFIRM" = "CANCEL" ]; then
        dialog --title "Info" --msgbox "Deletion aborted." 8 40
        clear
        exit 0
    fi

    if [ "$CONFIRM" = "$TABLE_NAME" ]; then
        if rm -f -- "$meta_file" "$data_file"; then
            dialog --title "Success" \
                   --msgbox "Table '$TABLE_NAME' deleted successfully." 8 50
            clear
            exit 0
        else
            dialog --title "Error" \
                   --msgbox "Failed to delete table '$TABLE_NAME'." 8 50
            clear
            exit 1
        fi
    else
        dialog --title "Error" \
               --msgbox "Names do not match.\nPlease type the table name exactly or CANCEL." \
               9 60
    fi
done
