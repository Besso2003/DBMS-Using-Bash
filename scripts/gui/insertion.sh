#!/bin/bash

# ==========================
# Insert Row (GUI)
# ==========================

db_path="$1"
tables_path="$db_path/tables"
mkdir -p "$tables_path"

# Use SCRIPT_DIR from selector or fallback to default GUI folder
SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}
source "$SCRIPT_DIR/dialog_ui.sh"

# --------------------------
# Helper dialogs
# --------------------------
show_error() {
    dialog --title "Error" --msgbox "$1" 8 50
}

show_info() {
    dialog --title "Success" --msgbox "$1" 8 50
}

# =========================
# Select Table
# =========================
while true; do
    TABLE_NAME=$(dialog --clear \
        --title "Insert Into Table" \
        --inputbox "Enter table name:" 10 50 \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0  # User pressed cancel

    TABLE_NAME=$(echo "$TABLE_NAME" | xargs)

    meta_file="$tables_path/$TABLE_NAME.meta"
    data_file="$tables_path/$TABLE_NAME.db"

    if [ -z "$TABLE_NAME" ]; then
        show_error "Table name cannot be empty."
    elif [ ! -f "$meta_file" ]; then
        show_error "Table '$TABLE_NAME' does not exist."
    elif [ ! -f "$data_file" ]; then
        show_error "Data file for table '$TABLE_NAME' does not exist."
    else
        break
    fi
done

# =========================
# Load Metadata
# =========================
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

row=()

# =========================
# Insert Row
# =========================
for ((i=0; i<columns; i++)); do
    while true; do
        VALUE=$(dialog --clear \
            --title "Insert Value" \
            --inputbox "Enter ${col_names[i]} (${col_types[i]}):" 10 50 \
            2>&1 >/dev/tty)

        [ $? -ne 0 ] && exit 0  # User pressed cancel

        VALUE=$(echo "$VALUE" | xargs)

        # Empty check
        if [ -z "$VALUE" ]; then
            show_error "Value cannot be empty."
            continue
        fi

        # Type validation
        if [ "${col_types[i]}" = "int" ] && ! [[ "$VALUE" =~ ^-?[0-9]+$ ]]; then
            show_error "Invalid integer value."
            continue
        fi

        # Primary Key validation
        if [ $((i+1)) -eq "$pk" ]; then
            if cut -d: -f"$pk" "$data_file" | grep -Fxq "$VALUE"; then
                show_error "Duplicate primary key value."
                continue
            fi
        fi

        row+=("$VALUE")
        break
    done
done

# =========================
# Save Row
# =========================
echo "$(IFS=:; echo "${row[*]}")" >> "$data_file"

show_info "Row inserted successfully into table '$TABLE_NAME'."

clear
