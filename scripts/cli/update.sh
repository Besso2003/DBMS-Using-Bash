#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

LEFT_PAD=10
source "$(dirname "$0")/ui.sh"

clear
echo

# =========================
# Header
# =========================
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                         UPDATE TABLE                                     ${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

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
            [[ "$value" =~ ^-?[0-9]+$ ]] && { echo "$value"; return; }
            left_text "${RED}Invalid integer. Try again.${RESET}"
        else
            [ -n "$value" ] && { echo "$value"; return; }
            left_text "${RED}Value cannot be empty. Try again.${RESET}"
        fi
    done
}

is_numeric() { [ "$1" = "int" ]; }

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
# Load metadata
# =========================
source "$meta_file"
IFS=':' read -ra col_names <<< "$names"
IFS=':' read -ra col_types <<< "$types"

# =========================
# Choose column to update
# =========================
echo
left_text "${YELLOW}Choose column to update:${RESET}"
for ((i=0;i<${#col_names[@]};i++)); do
    left_text "$((i+1))) ${col_names[i]}"
done

while true; do
    update_col=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Column number: " "int")
    [[ "$update_col" -ge 1 && "$update_col" -le "${#col_names[@]}" ]] && break
    left_text "${RED}Invalid column number.${RESET}"
done

UPDATE_TYPE="${col_types[$((update_col-1))]}"

# =========================
# New value
# =========================
echo
left_text "${YELLOW}Enter new value:${RESET}"

while true; do
    read -p "$(printf '%*s' $LEFT_PAD)New value: " NEW_VALUE

    if is_numeric "$UPDATE_TYPE"; then
        if [[ "$NEW_VALUE" =~ ^-?[0-9]+$ ]]; then
            if [ "$update_col" -eq "$pk" ] && ! [[ "$NEW_VALUE" =~ ^[0-9]+$ ]]; then
                left_text "${RED}Primary key must be non-negative.${RESET}"
            else
                break
            fi
        else
            left_text "${RED}Invalid integer.${RESET}"
        fi
    else
        [ -n "$NEW_VALUE" ] && break
        left_text "${RED}Value cannot be empty.${RESET}"
    fi
done

# =========================
# Condition column
# =========================
echo
left_text "${YELLOW}Choose condition column:${RESET}"
for ((i=0;i<${#col_names[@]};i++)); do
    left_text "$((i+1))) ${col_names[i]}"
done

while true; do
    cond_col=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Column number: " "int")
    [[ "$cond_col" -ge 1 && "$cond_col" -le "${#col_names[@]}" ]] && break
    left_text "${RED}Invalid column number.${RESET}"
done

COND_TYPE="${col_types[$((cond_col-1))]}"

# =========================
# Condition value
# =========================
echo
if is_numeric "$COND_TYPE"; then
    START_VAL=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Value: " "int")
    END_VAL="$START_VAL"
else
    COND_VALUE=$(get_valid_input "$(printf '%*s' $LEFT_PAD)Value: " "string")
fi

# =========================
# WARNING
# =========================
echo
left_text "${YELLOW}WARNING: Matching records will be updated permanently.${RESET}"
read -p "$(printf '%*s' $LEFT_PAD)Continue? [y/N]: " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

# =========================
# Apply update safely
# =========================
tmp_file=$(mktemp)

if is_numeric "$COND_TYPE"; then
    awk -F':' -v OFS=':' -v uc="$update_col" -v cv="$cond_col" -v nv="$NEW_VALUE" -v v="$START_VAL" '
    { if ($cv == v) $uc = nv; print }
    ' "$data_file" > "$tmp_file"
else
    awk -F':' -v OFS=':' -v uc="$update_col" -v cv="$cond_col" -v nv="$NEW_VALUE" -v v="$COND_VALUE" '
    { if ($cv == v) $uc = nv; print }
    ' "$data_file" > "$tmp_file"
fi

mv "$tmp_file" "$data_file"

echo
left_text "${GREEN}Update completed successfully.${RESET}"
echo
read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
