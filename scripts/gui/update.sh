#!/bin/bash

# ==========================
# Update Table (GUI)
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

# --------------------------
# Select Table
# --------------------------
while true; do
    TABLE_NAME=$(dialog --clear \
        --title "Update Table" \
        --inputbox "Enter table name:" 10 50 2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0

    TABLE_NAME=$(echo "$TABLE_NAME" | xargs)
    meta_file="$tables_path/$TABLE_NAME.meta"
    data_file="$tables_path/$TABLE_NAME.db"

    if [ -z "$TABLE_NAME" ]; then
        show_error "Table name cannot be empty."
    elif [ ! -f "$meta_file" ] || [ ! -f "$data_file" ]; then
        show_error "Table '$TABLE_NAME' does not exist."
    else
        break
    fi
done

# --------------------------
# Load metadata
# --------------------------
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

# --------------------------
# Select column to update
# --------------------------
COL_MENU=()
for ((i=0; i<${#col_names[@]}; i++)); do
    COL_MENU+=("$((i+1))" "${col_names[i]} (${col_types[i]})")
done

while true; do
    update_col=$(dialog --clear \
        --title "Choose Column" \
        --menu "Select the column to update:" 15 50 5 \
        "${COL_MENU[@]}" \
        2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0

    if [[ "$update_col" -ge 1 && "$update_col" -le "${#col_names[@]}" ]]; then
        break
    else
        show_error "Invalid column number."
    fi
done

UPDATE_TYPE="${col_types[$((update_col-1))]}"

# --------------------------
# Enter new value
# --------------------------
while true; do
    NEW_VALUE=$(dialog --clear \
        --title "New Value" \
        --inputbox "Enter new value for ${col_names[$((update_col-1))]} (${UPDATE_TYPE}):" 10 50 2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0
    NEW_VALUE=$(echo "$NEW_VALUE" | xargs)

    if [ "$UPDATE_TYPE" = "int" ]; then
        if ! [[ "$NEW_VALUE" =~ ^-?[0-9]+$ ]]; then
            show_error "Invalid integer."
            continue
        fi
        if [ "$update_col" -eq "$pk" ] && ! [[ "$NEW_VALUE" =~ ^[0-9]+$ ]]; then
            show_error "Primary key must be a non-negative integer."
            continue
        fi
    else
        [ -z "$NEW_VALUE" ] && { show_error "Value cannot be empty."; continue; }
    fi
    break
done

# --------------------------
# Select condition column/value
# --------------------------
if [ "$update_col" -eq "$pk" ]; then
    # Updating primary key requires old PK value
    while true; do
        OLD_PK=$(dialog --clear \
            --title "Old Primary Key" \
            --inputbox "Enter old primary key value:" 10 50 2>&1 >/dev/tty)
        [ $? -ne 0 ] && exit 0
        OLD_PK=$(echo "$OLD_PK" | xargs)
        [[ "$OLD_PK" =~ ^[0-9]+$ ]] && break || show_error "Invalid primary key value."
    done
    cond_col="$pk"
    START_VAL="$OLD_PK"
    END_VAL="$OLD_PK"
else
    # Select condition column
    COND_MENU=()
    for ((i=0; i<${#col_names[@]}; i++)); do
        COND_MENU+=("$((i+1))" "${col_names[i]} (${col_types[i]})")
    done

    while true; do
        cond_col=$(dialog --clear \
            --title "Condition Column" \
            --menu "Select condition column:" 15 50 5 \
            "${COND_MENU[@]}" 2>&1 >/dev/tty)
        [ $? -ne 0 ] && exit 0

        if [[ "$cond_col" -ge 1 && "$cond_col" -le "${#col_names[@]}" ]]; then
            break
        else
            show_error "Invalid column number."
        fi
    done

    COND_TYPE="${col_types[$((cond_col-1))]}"

    if [ "$COND_TYPE" = "int" ]; then
        while true; do
            START_VAL=$(dialog --clear --title "Condition Start Value" --inputbox "Enter start value:" 10 50 2>&1 >/dev/tty)
            [ $? -ne 0 ] && exit 0
            START_VAL=$(echo "$START_VAL" | xargs)

            END_VAL=$(dialog --clear --title "Condition End Value" --inputbox "Enter end value (leave empty for single):" 10 50 2>&1 >/dev/tty)
            [ $? -ne 0 ] && exit 0
            END_VAL=$(echo "$END_VAL" | xargs)
            [ -z "$END_VAL" ] && END_VAL="$START_VAL"

            if [[ "$START_VAL" =~ ^-?[0-9]+$ && "$END_VAL" =~ ^-?[0-9]+$ ]]; then
                [[ "$START_VAL" -le "$END_VAL" ]] && break || show_error "Start cannot be greater than end."
            else
                show_error "Invalid integer values."
            fi
        done
    else
        while true; do
            COND_VALUE=$(dialog --clear --title "Condition Value" --inputbox "Enter string condition value (exact match):" 10 50 2>&1 >/dev/tty)
            [ $? -ne 0 ] && exit 0
            COND_VALUE=$(echo "$COND_VALUE" | xargs)
            [ -n "$COND_VALUE" ] && break
            show_error "Condition value cannot be empty."
        done
    fi
fi

# --------------------------
# Perform update safely
# --------------------------
tmp_file=$(mktemp) || exit 1

# Check PK uniqueness
if [ "$update_col" -eq "$pk" ]; then
    if awk -F':' -v c="$pk" -v newv="$NEW_VALUE" -v oldv="$OLD_PK" '($c==newv && $c!=oldv){found=1; exit} END{if(found) exit 0; exit 1}' "$data_file"; then
        show_error "Another record already uses primary key '$NEW_VALUE'. Update aborted."
        rm -f "$tmp_file"
        exit 1
    fi
fi

if [ "$COND_TYPE" = "int" ]; then
    awk -F':' -v OFS=':' -v uc="$update_col" -v cv="$cond_col" -v nv="$NEW_VALUE" -v s="$START_VAL" -v e="$END_VAL" \
        '{if (($cv+0)>=(s+0)&&($cv+0)<=(e+0)) $uc=nv; print}' "$data_file" > "$tmp_file" || { rm -f "$tmp_file"; show_error "Update failed."; exit 1; }
else
    awk -F':' -v OFS=':' -v uc="$update_col" -v cv="$cond_col" -v nv="$NEW_VALUE" -v cond="$COND_VALUE" \
        '{if ($cv==cond) $uc=nv; print}' "$data_file" > "$tmp_file" || { rm -f "$tmp_file"; show_error "Update failed."; exit 1; }
fi

mv "$tmp_file" "$data_file"
show_info "Update completed successfully."
clear
