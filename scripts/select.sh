#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$(dirname "$0")/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                        SELECT FROM TABLE                               ${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

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
                if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                left_text "${RED}Invalid integer. Try again.${RESET}" >&2
                continue
            fi
        else
            if [ -z "$value" ]; then
                left_text "${RED}Value cannot be empty. Try again.${RESET}" >&2
                continue
            fi
        fi

        echo "$value"
        break
    done
}

is_numeric() {
    [ "$1" = "int" ]
}

safe_sort() {
    if [ -n "$pk" ]; then
        sort -t':' -k"${pk},${pk}"n
    else
        cat
    fi
}

# =========================
# Choose table
# =========================
while true; do
    read -p "$(printf '%*s' $LEFT_PAD)Enter Table Name: " table_name
    meta_file="$tables_path/$table_name.meta"
    data_file="$tables_path/$table_name.db"

    if [ -z "$table_name" ]; then
        left_text "${RED}Table name cannot be empty.${RESET}"
    elif [ ! -f "$meta_file" ] || [ ! -f "$data_file" ]; then
        left_text "${RED}Table '$table_name' does not exist.${RESET}"
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
# Select mode
# =========================
while true; do
    echo
    left_text "${YELLOW}Select Mode:${RESET}"
    left_text "1) Select All"
    left_text "2) Select With Condition"
    
    choice=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Choose option [1-2]: " "int")
    if [[ "$choice" -ge 1 && "$choice" -le 2 ]]; then
        break
    else
        left_text "${RED}Invalid option. Please enter 1 or 2.${RESET}"
    fi
done

# Function to print a row nicely
print_row() {
    local row="$1"
    IFS=':' read -ra fields <<< "$row"
    printf "%*s" "$LEFT_PAD" ""
    for f in "${fields[@]}"; do
        printf "%-15s" "$f"
    done
    echo
}

# =========================
# SELECT ALL
# =========================
if [ "$choice" -eq 1 ]; then
    echo
    print_row "$names"
    echo
    while IFS= read -r line; do
        print_row "$line"
    done < <(cat "$data_file" | safe_sort)
    read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
    exit 0
fi

# =========================
# SELECT WITH CONDITION
# =========================
echo
left_text "${YELLOW}Choose column:${RESET}"
for ((i=0; i<${#col_names[@]}; i++)); do
    left_text "$((i+1))) ${col_names[i]}"
done

while true; do
    col_num=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Column number: " "int")
    if [[ "$col_num" -ge 1 && "$col_num" -le "${#col_names[@]}" ]]; then
        break
    else
        left_text "${RED}Invalid column number. Please choose a valid column.${RESET}"
    fi
done

COL_INDEX="$col_num"
COL_NAME="${col_names[$((col_num-1))]}"
COL_TYPE="${col_types[$((col_num-1))]}"

# =========================
# Apply filtering
# =========================
if is_numeric "$COL_TYPE"; then
    left_text "${YELLOW}Numeric filter:${RESET}"
    while true; do
        START_VAL=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Start value: " "$COL_TYPE")
        read -p "$(printf '%*s' $LEFT_PAD '')End value (press Enter for single value): " END_VAL
        [ -z "$END_VAL" ] && END_VAL="$START_VAL"

        if [[ "$START_VAL" =~ ^-?[0-9]+$ && "$END_VAL" =~ ^-?[0-9]+$ ]]; then
            # If filtering by primary key, enforce non-negative integers
            if [ "$COL_INDEX" -eq "$pk" ] && ( ! [[ "$START_VAL" =~ ^[0-9]+$ ]] || ! [[ "$END_VAL" =~ ^[0-9]+$ ]] ); then
                left_text "${RED}Primary key filter requires non-negative integers. Try again.${RESET}"
                continue
            fi
            break
        else
            left_text "${RED}Invalid integer values. Try again.${RESET}"
        fi
    done

    echo
    # Print table header
    print_row "$names"

    echo
    # Print filtered rows
    while IFS= read -r line; do
        print_row "$line"
    done < <(
        awk -F':' -v c="$COL_INDEX" -v s="$START_VAL" -v e="$END_VAL" '($c+0) >= (s+0) && ($c+0) <= (e+0)' "$data_file" | safe_sort
    )

else
    left_text "${YELLOW}String filter (exact match):${RESET}"
    VAL=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Value: " "string")

    # Print table header
    echo
    print_row "$names"

    echo
    # Print filtered rows
    while IFS= read -r line; do
        print_row "$line"
    done < <(
        awk -F':' -v c="$COL_INDEX" -v v="$VAL" '$c == v' "$data_file" | safe_sort
    )
fi

# Pause so user can see result
echo
read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
