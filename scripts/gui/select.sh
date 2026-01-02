#!/bin/bash

# ==========================
# Select From Table (GUI)
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
    dialog --title "Info" --msgbox "$1" 8 50
}

# --------------------------
# Select Table
# --------------------------
while true; do
    TABLE_NAME=$(dialog --clear \
        --title "Select Table" \
        --inputbox "Enter table name:" 10 50 \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0  # Cancel pressed

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
# Load Metadata
# --------------------------
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

# --------------------------
# Select Mode
# --------------------------
while true; do
    MODE=$(dialog --clear \
        --title "Select Mode" \
        --menu "Choose option:" 10 50 2 \
        1 "Select All" \
        2 "Select With Condition" \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0

    if [[ "$MODE" == "1" || "$MODE" == "2" ]]; then
        break
    else
        show_error "Invalid option. Please choose 1 or 2."
    fi
done

# --------------------------
# Function to display rows
# --------------------------
display_rows() {
    local rows="$1"
    tmpfile=$(mktemp)
    echo "$rows" | column -t -s':' > "$tmpfile"
    dialog --title "Table Data" --textbox "$tmpfile" 20 80
    rm -f "$tmpfile"
}

# --------------------------
# SELECT ALL
# --------------------------
if [ "$MODE" -eq 1 ]; then
    all_data="$names"$'\n'"$(cat "$data_file")"
    display_rows "$all_data"
    clear
    exit 0
fi

# --------------------------
# SELECT WITH CONDITION
# --------------------------
COL_OPTIONS=()
for ((i=0; i<${#col_names[@]}; i++)); do
    COL_OPTIONS+=($((i+1)) "${col_names[i]}")
done

while true; do
    COL_NUM=$(dialog --clear \
        --title "Choose Column" \
        --menu "Select column to filter:" 15 50 5 \
        "${COL_OPTIONS[@]}" \
        2>&1 >/dev/tty)

    [ $? -ne 0 ] && exit 0

    if [[ "$COL_NUM" -ge 1 && "$COL_NUM" -le "${#col_names[@]}" ]]; then
        break
    else
        show_error "Invalid column number."
    fi
done

COL_INDEX="$COL_NUM"
COL_NAME="${col_names[$((COL_NUM-1))]}"
COL_TYPE="${col_types[$((COL_NUM-1))]}"

# --------------------------
# Apply Filtering
# --------------------------
if [ "$COL_TYPE" = "int" ]; then
    while true; do
        START_VAL=$(dialog --inputbox "Enter start value for $COL_NAME:" 10 50 2>&1 >/dev/tty)
        [ $? -ne 0 ] && exit 0
        END_VAL=$(dialog --inputbox "Enter end value for $COL_NAME (leave empty for single value):" 10 50 2>&1 >/dev/tty)
        [ $? -ne 0 ] && exit 0

        START_VAL=$(echo "$START_VAL" | xargs)
        END_VAL=$(echo "$END_VAL" | xargs)
        [ -z "$END_VAL" ] && END_VAL="$START_VAL"

        if [[ "$START_VAL" =~ ^-?[0-9]+$ && "$END_VAL" =~ ^-?[0-9]+$ ]]; then
            if [[ "$COL_INDEX" -eq "$pk" ]] && ( ! [[ "$START_VAL" =~ ^[0-9]+$ ]] || ! [[ "$END_VAL" =~ ^[0-9]+$ ]] ); then
                show_error "Primary key must be non-negative integers."
                continue
            fi
            break
        else
            show_error "Invalid integer values. Try again."
        fi
    done

    filtered_rows=$(awk -F':' -v c="$COL_INDEX" -v s="$START_VAL" -v e="$END_VAL" '($c+0) >= (s+0) && ($c+0) <= (e+0)' "$data_file")
else
    VAL=$(dialog --inputbox "Enter value for $COL_NAME:" 10 50 2>&1 >/dev/tty)
    [ $? -ne 0 ] && exit 0
    VAL=$(echo "$VAL" | xargs)
    filtered_rows=$(awk -F':' -v c="$COL_INDEX" -v v="$VAL" '$c == v' "$data_file")
fi

# --------------------------
# Display filtered results
# --------------------------
all_data="$names"$'\n'"$filtered_rows"
display_rows "$all_data"
clear
