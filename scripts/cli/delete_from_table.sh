#!/bin/bash

# =========================
# Delete From Table (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"
TABLES_PATH="$DB_PATH/tables"

LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                        DELETE FROM TABLE                              ${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# =========================
# Input validation
# =========================
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                left_text "${RED}Invalid input. Enter a number.${RESET}"
                continue
            fi
        else
            if [ -z "$value" ]; then
                left_text "${RED}Value cannot be empty.${RESET}"
                continue
            fi
        fi

        echo "$value"
        return
    done
}

# =========================
# Choose table
# =========================
while true; do
    read -p "$(printf '%*s' $LEFT_PAD)Enter Table Name: " table_name
    meta_file="$TABLES_PATH/$table_name.meta"
    data_file="$TABLES_PATH/$table_name.db"

    if [ -z "$table_name" ]; then
        left_text "${RED}Table name cannot be empty.${RESET}"
    elif [ ! -f "$meta_file" ] || [ ! -f "$data_file" ]; then
        left_text "${RED}Table '$table_name' does not exist.${RESET}"
    else
        break
    fi
done

# =========================
# Load metadata
# =========================
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

# =========================
# Delete menu
# =========================
while true; do
    echo
    left_text "${YELLOW}Delete By:${RESET}"
    left_text "1) Primary Key"
    left_text "2) Condition (Column = Value)"
    left_text "3) Delete All Records"

    choice=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Choose option [1-3]: " "int")

    case "$choice" in
        1)
            # ===== Delete by PK =====
            pk_name="${col_names[$((pk-1))]}"
            pk_type="${col_types[$((pk-1))]}"

            while true; do
                pk_value=$(get_valid_input \
                    "$(printf '%*s' $LEFT_PAD)Enter Primary Key '$pk_name': " \
                    "$pk_type")

                if [[ "$pk_type" = "int" && ! "$pk_value" =~ ^[0-9]+$ ]]; then
                    left_text "${RED}Primary key must be a non-negative integer.${RESET}"
                    continue
                fi
                break
            done

            if awk -F: -v c="$pk" -v v="$pk_value" '$c == v {found=1} END{exit !found}' "$data_file"; then
                awk -F: -v c="$pk" -v v="$pk_value" '$c != v' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                left_text "${GREEN}Record deleted successfully.${RESET}"
                break
            else
                left_text "${RED}Primary key not found.${RESET}"
            fi
            ;;
        2)
            # ===== Delete by condition =====
            left_text "${YELLOW}Choose column:${RESET}"
            for ((i=0; i<${#col_names[@]}; i++)); do
                left_text "$((i+1))) ${col_names[i]}"
            done

            col_num=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Column number: " "int")

            if [[ "$col_num" -lt 1 || "$col_num" -gt "${#col_names[@]}" ]]; then
                left_text "${RED}Invalid column number.${RESET}"
                continue
            fi

            col_name="${col_names[$((col_num-1))]}"
            col_type="${col_types[$((col_num-1))]}"

            col_value=$(get_valid_input \
                "$(printf '%*s' $LEFT_PAD)Enter value for $col_name: " \
                "$col_type")

            if awk -F: -v c="$col_num" -v v="$col_value" '$c == v {found=1} END{exit !found}' "$data_file"; then
                awk -F: -v c="$col_num" -v v="$col_value" '$c != v' "$data_file" > "$tmp_file"
                mv "$tmp_file" "$data_file"
                left_text "${GREEN}Matching record(s) deleted.${RESET}"
                break
            else
                left_text "${RED}No matching records found.${RESET}"
            fi
            ;;
        3)
            # ===== Delete all =====
            echo
            left_text "${YELLOW}WARNING: This will delete ALL records in the table!${RESET}"
            read -p "$(printf '%*s' $LEFT_PAD)Are you sure you want to continue? [y/N]: " confirm

            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                > "$data_file"
                left_text "${GREEN}All records deleted.${RESET}"
                break
            else
                left_text "${YELLOW}Deletion cancelled.${RESET}"
            fi
            ;;
        *)
            left_text "${RED}Invalid choice. Choose [1-3].${RESET}"
            ;;
    esac
done

echo
read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
clear
