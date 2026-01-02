#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

mkdir -p "$tables_path"

# Dialog helpers
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
        --title "Delete From Table" \
        --inputbox "Enter table name:" 10 50 2>&1 >/dev/tty)

    if [ $? -ne 0 ]; then
        dialog --msgbox "Operation cancelled." 8 40
        clear
        exit 0
    fi

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

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

# =========================
# Delete Menu
# =========================
while true; do
    CHOICE=$(dialog --clear --menu "Delete Options for $TABLE_NAME" 15 60 4 \
        1 "Delete by Primary Key" \
        2 "Delete by Column = Value" \
        3 "Delete All Records" \
        4 "Cancel" 2>&1 >/dev/tty)

    case "$CHOICE" in
        1)
            # Delete by Primary Key
            PK_COL="${col_names[$((pk-1))]}"
            while true; do
                PK_VALUE=$(dialog --inputbox "Enter Primary Key value for '$PK_COL':" 10 50 2>&1 >/dev/tty)
                if [ $? -ne 0 ]; then break 2; fi
                PK_VALUE=$(echo "$PK_VALUE" | xargs)

                if [ "${col_types[$((pk-1))]}" = "int" ] && ! [[ "$PK_VALUE" =~ ^[0-9]+$ ]]; then
                    show_error "Primary key must be a non-negative integer."
                    continue
                fi

                if awk -F: -v pk="$pk" -v val="$PK_VALUE" '$pk == val {found=1} END{exit !found}' "$data_file"; then
                    awk -F: -v pk="$pk" -v val="$PK_VALUE" '$pk != val' "$data_file" > "$tmp_file"
                    mv "$tmp_file" "$data_file"
                    show_info "Record deleted successfully."
                    break
                else
                    show_error "Primary Key not found."
                fi
            done
            ;;
        2)
            # Delete by Column = Value
            COL_MENU=()
            for i in "${!col_names[@]}"; do
                COL_MENU+=("$((i+1))" "${col_names[i]}")
            done


            COL_NUM=$(dialog --menu "Choose Column" 15 60 4 "${COL_MENU[@]}" 2>&1 >/dev/tty)
            if [ $? -ne 0 ]; then break; fi

            COL_IDX=$((COL_NUM-1))
            COL_NAME="${col_names[$COL_IDX]}"
            COL_TYPE="${col_types[$COL_IDX]}"

            COL_VALUE=$(dialog --inputbox "Enter value for $COL_NAME ($COL_TYPE):" 10 50 2>&1 >/dev/tty)
            if [ $? -ne 0 ]; then break; fi
            COL_VALUE=$(echo "$COL_VALUE" | xargs)

            if awk -F: -v c="$COL_NUM" -v v="$COL_VALUE" '$c == v {found=1} END{exit !found}' "$data_file"; then
                awk -F: -v c="$COL_NUM" -v v="$COL_VALUE" '$c != v' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                show_info "Record(s) where '$COL_NAME' = '$COL_VALUE' deleted successfully."
            else
                show_error "No matching records found."
            fi
            ;;
        3)
            # Delete All Records
            dialog --yesno "Are you sure you want to delete ALL records in '$TABLE_NAME'?" 10 50
            if [ $? -eq 0 ]; then
                > "$data_file"
                show_info "All records deleted."
            else
                show_error "Deletion cancelled."
            fi
            ;;
        4|*)
            clear
            exit 0
            ;;
    esac
done

clear
