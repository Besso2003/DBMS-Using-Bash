#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

db_path="$1"
tables_path="$db_path/tables"

clear
echo -e "${CYAN}===== SELECT FROM TABLE =====${RESET}"

# =========================
# Input validation helpers
# =========================
get_valid_input() {
    local prompt="$1"
    local type="$2"
    local value

    while true; do
        read -p "$prompt" value

        if [ "$type" = "int" ]; then
            [[ "$value" =~ ^[0-9]+$ ]] || {
                echo -e "${RED}Invalid integer. Try again.${RESET}"
                continue
            }
        else
            [ -z "$value" ] && {
                echo -e "${RED}Value cannot be empty. Try again.${RESET}"
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
# Select type
# =========================
echo
echo -e "${YELLOW}Select Mode:${RESET}"
echo "1) Select All"
echo "2) Select With Condition"

choice=$(get_valid_input "Choose option [1-2]: " "int")

# =========================
# SELECT ALL
# =========================
if [ "$choice" -eq 1 ]; then
    awk -F':' -v cols="$columns" '
        (cols=="" || NF==cols)
    ' "$data_file" |
    sort -t':' -k"${pk},${pk}"n |
    {
        echo "$names"
        cat
    }
    exit 0
fi

# =========================
# SELECT WITH CONDITION
# =========================
echo
echo -e "${YELLOW}Choose column:${RESET}"
for ((i=0; i<${#col_names[@]}; i++)); do
    echo "$((i+1))) ${col_names[i]}"
done

col_num=$(get_valid_input "Column number: " "int")

if [ "$col_num" -lt 1 ] || [ "$col_num" -gt "${#col_names[@]}" ]; then
    echo -e "${RED}Invalid column number.${RESET}"
    exit 1
fi

COL_INDEX="$col_num"
COL_NAME="${col_names[$((col_num-1))]}"
COL_TYPE="${col_types[$((col_num-1))]}"

# =========================
# Apply filtering
# =========================
if is_numeric "$COL_TYPE"; then
    echo -e "${YELLOW}Numeric filter:${RESET}"
    START_VAL=$(get_valid_input "Start value: " "$COL_TYPE")
    read -p "End value (press Enter for single value): " END_VAL
    [ -z "$END_VAL" ] && END_VAL="$START_VAL"

    # Validate numeric
    num_re='^-?[0-9]+(\.[0-9]+)?$'
    [[ "$START_VAL" =~ $num_re && "$END_VAL" =~ $num_re ]] || {
        echo -e "${RED}Invalid numeric values.${RESET}"
        exit 1
    }

    awk -F':' -v c="$COL_INDEX" -v s="$START_VAL" -v e="$END_VAL" -v cols="$columns" '
        (cols=="" || NF==cols) &&
        ($c+0) >= (s+0) &&
        ($c+0) <= (e+0)
    ' "$data_file" |
    sort -t':' -k"${pk},${pk}"n |
    {
        echo "$names"
        cat
    }

else
    echo -e "${YELLOW}String filter (exact match):${RESET}"
    VAL=$(get_valid_input "Value: " "string")

    awk -F':' -v c="$COL_INDEX" -v v="$VAL" -v cols="$columns" '
        (cols=="" || NF==cols) && $c == v
    ' "$data_file" |
    sort -t':' -k"${pk},${pk}"n |
    {
        echo "$names"
        cat
    }
fi
