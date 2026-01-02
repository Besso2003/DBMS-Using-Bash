#!/bin/bash

# ==========================
# Create Table (GUI)
# ==========================

db_path="$1"
tables_path="$db_path/tables"
mkdir -p "$tables_path"

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

# --------------------------
# Table Name
# --------------------------
while true; do
    TABLE_NAME=$(dialog --clear \
        --title "Create Table" \
        --inputbox "Enter table name:" 10 50 \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0

    TABLE_NAME=$(echo "$TABLE_NAME" | xargs)

    if [ -z "$TABLE_NAME" ]; then
        show_error "Table name cannot be empty."
    elif [[ ! "$TABLE_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        show_error "Invalid table name format."
    elif [ -f "$tables_path/$TABLE_NAME.meta" ]; then
        show_error "Table '$TABLE_NAME' already exists."
    else
        meta_file="$tables_path/$TABLE_NAME.meta"
        data_file="$tables_path/$TABLE_NAME.db"
        break
    fi
done

# --------------------------
# Number of Columns
# --------------------------
while true; do
    COLS=$(dialog --clear \
        --title "Number of Columns" \
        --inputbox "Enter number of columns:" 10 50 \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0

    if [[ ! "$COLS" =~ ^[1-9][0-9]*$ ]]; then
        show_error "Column count must be a positive number."
    else
        break
    fi
done

col_names=()
col_types=()

# --------------------------
# Column Names & Types
# --------------------------
for ((i=1; i<=COLS; i++)); do

    while true; do
        COL_NAME=$(dialog --clear \
            --title "Column $i Name" \
            --inputbox "Enter column $i name:" 10 50 \
            2>&1 >/dev/tty)

        [ $? -ne 0 ] && exit 0

        COL_NAME=$(echo "$COL_NAME" | xargs)

        if [ -z "$COL_NAME" ]; then
            show_error "Column name cannot be empty."
        elif [[ " ${col_names[*]} " == *" $COL_NAME "* ]]; then
            show_error "Duplicate column name."
        else
            col_names+=("$COL_NAME")
            break
        fi
    done

    while true; do
        COL_TYPE=$(dialog --clear \
            --title "Column $i Type" \
            --menu "Choose datatype for '$COL_NAME':" 10 50 2 \
            1 "int" \
            2 "string" \
            2>&1 >/dev/tty)

        [ $? -ne 0 ] && exit 0

        case "$COL_TYPE" in
            1) col_types+=("int"); break ;;
            2) col_types+=("string"); break ;;
            *) show_error "Invalid datatype selection." ;;
        esac
    done
done

# --------------------------
# Primary Key Selection
# --------------------------
PK_MENU=""
for ((i=0; i<COLS; i++)); do
    PK_MENU+="$((i+1)) ${col_names[i]} "
done

while true; do
    PK=$(dialog --clear \
        --title "Primary Key" \
        --menu "Select Primary Key column:" 12 50 "$COLS" \
        $PK_MENU \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0

    if [[ "$PK" =~ ^[0-9]+$ && "$PK" -ge 1 && "$PK" -le "$COLS" ]]; then
        break
    else
        show_error "Invalid primary key selection."
    fi
done

# --------------------------
# Write Metadata
# --------------------------
{
    echo "pk=$PK"
    echo "columns=$COLS"
    echo "types=$(IFS=:; echo "${col_types[*]}")"
    echo "names=$(IFS=:; echo "${col_names[*]}")"
} > "$meta_file"

touch "$data_file"

show_info "Table '$TABLE_NAME' created successfully.\nPrimary Key: ${col_names[$((PK-1))]}"
clear
