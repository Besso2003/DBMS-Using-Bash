#!/bin/bash

# =========================
# Insert Into Table (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"
TABLES_PATH="$DB_PATH/tables"

LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

# override left_text for stderr optionally
left_text() {
    local msg="$1"
    local stream="${2:-stdout}"
    if [ "$stream" = "stderr" ]; then
        printf "%*s%s\n" "$LEFT_PAD" "" "$(echo -e "$msg")" >&2
    else
        printf "%*s%s\n" "$LEFT_PAD" "" "$(echo -e "$msg")"
    fi
}

# =========================
# Input validation function
# =========================
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                left_text "${RED}Invalid integer. Try again.${RESET}" stderr
                continue
            fi
        else
            if [ -z "$value" ]; then
                left_text "${RED}Value cannot be empty. Try again.${RESET}" stderr
                continue
            fi
        fi

        echo "$value"
        return
    done
}

# =========================
# Start insert
# =========================
clear
echo
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                         INSERT INTO TABLE                             ${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Get table name
while true; do
    read -p "$(printf '%*s' $LEFT_PAD)Enter Table Name: " table_name
    meta_file="$TABLES_PATH/$table_name.meta"
    data_file="$TABLES_PATH/$table_name.db"

    if [ -z "$table_name" ]; then
        left_text "${RED}Error: Table name cannot be empty.${RESET}" stderr
    elif [ ! -f "$meta_file" ]; then
        left_text "${RED}Error: Table '$table_name' does not exist.${RESET}" stderr
    elif [ ! -f "$data_file" ]; then
        left_text "${RED}Error: Data file for table '$table_name' does not exist.${RESET}" stderr
    else
        break
    fi
done

# Load metadata
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

row=()
pk_value=""

left_text "${YELLOW}Enter values for the new row:${RESET}"
echo

# Insert values with validation
for ((i=0; i<columns; i++)); do
    while true; do
        value=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Enter ${col_names[i]} (${col_types[i]}): " "${col_types[i]}")

        # Primary Key uniqueness validation
        if [ $((i+1)) -eq "$pk" ]; then
            if [[ "${col_types[i]}" = "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                left_text "${RED}Primary key must be a non-negative integer.${RESET}" stderr
                continue
            fi

            if cut -d: -f"$pk" "$data_file" | grep -Fxq "$value"; then
                left_text "${RED}Duplicate primary key. Enter a unique value.${RESET}" stderr
                continue
            fi
            pk_value="$value"
        fi

        row+=("$value")
        break
    done
done

# Append to data file
echo "$(IFS=:; echo "${row[*]}")" >> "$data_file"
left_text "${GREEN}Row inserted successfully into table '$table_name'.${RESET}"
echo

read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
clear
