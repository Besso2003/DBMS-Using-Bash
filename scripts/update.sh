#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"

clear
echo -e "${CYAN}===== UPDATE TABLE =====${RESET}"

# =========================
# Helpers
# =========================
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            [[ "$value" =~ ^[0-9]+$ ]] || {
                echo -e "${RED}Invalid integer.${RESET}"
                continue
            }
        else
            [ -z "$value" ] && {
                echo -e "${RED}Value cannot be empty.${RESET}"
                continue
            }
        fi

        echo "$value"
        return
    done
}

is_numeric() {
    case "$1" in
        int|float|double) return 0 ;;
        *) return 1 ;;
    esac
}

is_number_value() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

# =========================
# Choose table
# =========================
while true; do
    read -p "Enter Table Name: " table_name
    meta_file="$tables_path/$table_name.meta"
    data_file="$tables_path/$table_name.db"

    if [ -z "$table_name" ]; then
        echo -e "${RED}Table name cannot be empty.${RESET}"
    elif [ ! -f "$meta_file" ] || [ ! -f "$data_file" ]; then
        echo -e "${RED}Table '$table_name' does not exist.${RESET}"
    else
        break
    fi
done

# =========================
# Load meta
# =========================
source "$meta_file"

IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

# =========================
# Choose column to update
# =========================
echo
echo -e "${YELLOW}Choose column to update:${RESET}"
for ((i=0; i<${#col_names[@]}; i++)); do
    echo "$((i+1))) ${col_names[i]}"
done

update_col=$(get_valid_input "Column number: " "int")

if [ "$update_col" -lt 1 ] || [ "$update_col" -gt "${#col_names[@]}" ]; then
    echo -e "${RED}Invalid column number.${RESET}"
    exit 1
fi

UPDATE_TYPE="${col_types[$((update_col-1))]}"

# =========================
# New value
# =========================
read -p "New value: " NEW_VALUE

if is_numeric "$UPDATE_TYPE"; then
    is_number_value "$NEW_VALUE" || {
        echo -e "${RED}Invalid numeric value.${RESET}"
        exit 1
    }
else
    [ -z "$NEW_VALUE" ] && {
        echo -e "${RED}Value cannot be empty.${RESET}"
        exit 1
    }
fi

# =========================
# Condition column
# =========================
echo
echo -e "${YELLOW}Choose condition column:${RESET}"
for ((i=0; i<${#col_names[@]}; i++)); do
    echo "$((i+1))) ${col_names[i]}"
done

cond_col=$(get_valid_input "Column number: " "int")

if [ "$cond_col" -lt 1 ] || [ "$cond_col" -gt "${#col_names[@]}" ]; then
    echo -e "${RED}Invalid column number.${RESET}"
    exit 1
fi

COND_TYPE="${col_types[$((cond_col-1))]}"

# =========================
# Condition values
# =========================
if is_numeric "$COND_TYPE"; then
    START_VAL=$(get_valid_input "Condition start value: " "$COND_TYPE")
    read -p "Condition end value (press Enter for single value): " END_VAL
    [ -z "$END_VAL" ] && END_VAL="$START_VAL"

    # Validate numeric
    is_number_value "$START_VAL" || { echo -e "${RED}Invalid start value.${RESET}"; exit 1; }
    is_number_value "$END_VAL" || { echo -e "${RED}Invalid end value.${RESET}"; exit 1; }

    # Ensure start <= end
    cmp_ok=$(awk -v s="$START_VAL" -v e="$END_VAL" 'BEGIN{if((s+0) <= (e+0)) print 1; else print 0}')
    [ "$cmp_ok" -ne 1 ] && { echo -e "${RED}Start greater than end.${RESET}"; exit 1; }
else
    read -p "Condition value (exact match): " COND_VALUE
    [ -z "$COND_VALUE" ] && { echo -e "${RED}Condition cannot be empty.${RESET}"; exit 1; }
fi

# =========================
# Safe update (transaction)
# =========================
tmp_file=$(mktemp) || exit 1

awk -F':' -v OFS=':' \
    -v uc="$update_col" \
    -v cv="$cond_col" \
    -v nv="$NEW_VALUE" \
    -v s="$START_VAL" \
    -v e="$END_VAL" \
    -v cond="$COND_VALUE" \
    -v cols="$columns" '
    (cols=="" || NF==cols) {
        if ('"$(is_numeric "$COND_TYPE" && echo 1 || echo 0)"' == 1) {
            # Numeric range update
            if (($cv+0) >= (s+0) && ($cv+0) <= (e+0)) {
                $uc = nv
            }
        } else {
            # String exact match
            if ($cv == cond) {
                $uc = nv
            }
        }
        print
    }
' "$data_file" > "$tmp_file" || {
    rm -f "$tmp_file"
    echo -e "${RED}Update failed.${RESET}"
    exit 1
}

# =========================
# Commit
# =========================
mv "$tmp_file" "$data_file"

echo -e "${GREEN}Update completed successfully.${RESET}"
exit 0
