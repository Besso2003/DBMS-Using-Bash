#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$(dirname \"$0\")/ui.sh"

clear
echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                                         UPDATE TABLE                                     ${RESET}"
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
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
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
    printf '%*s' "$LEFT_PAD"
    read -p "Enter Table Name: " table_name
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
# Choose column to update
# =========================
echo
left_text "${YELLOW}Choose column to update:${RESET}"
for ((i=0; i<${#col_names[@]}; i++)); do
    left_text "$((i+1))) ${col_names[i]}"
done

while true; do
    update_col=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Column number: " "int")
    if [[ "$update_col" -ge 1 && "$update_col" -le "${#col_names[@]}" ]]; then
        break
    else
        left_text "${RED}Invalid column number. Please choose a valid column.${RESET}"
    fi
done

UPDATE_TYPE="${col_types[$((update_col-1))]}"

# =========================
# New value
# =========================
echo
left_text "${YELLOW}Enter new value:${RESET}"

while true; do
    read -p "$(printf '%*s' $LEFT_PAD '')New value: " NEW_VALUE

    if is_numeric "$UPDATE_TYPE"; then
        if [[ "$NEW_VALUE" =~ ^-?[0-9]+$ ]]; then
            # If updating primary key, check uniqueness
            # uniqueness check deferred until condition (to allow updating to same value)
            break
        else
            left_text "${RED}Invalid integer. Try again.${RESET}"
        fi
    else
        if [ -n "$NEW_VALUE" ]; then
            # If updating primary key, check uniqueness
            # uniqueness check deferred until condition (to allow updating to same value)
            break
        else
            left_text "${RED}Value cannot be empty. Try again.${RESET}"
        fi
    fi
done

# =========================
# Condition (either skip selection for PK-update or ask user for condition column)
# =========================
echo
if [ "$update_col" -eq "$pk" ]; then
    # When updating PK, condition must be on PK; ask directly for old PK value
    cond_col="$pk"
    COND_TYPE="${col_types[$((cond_col-1))]}"
    left_text "${YELLOW}You are updating the primary key. Provide the old primary key value to identify the record:${RESET}"
    if is_numeric "$COND_TYPE"; then
        START_VAL=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Old ${col_names[$((pk-1))]} value: " "$COND_TYPE")
        END_VAL="$START_VAL"
    else
        while true; do
            read -p "$(printf '%*s' $LEFT_PAD '')Old ${col_names[$((pk-1))]} value: " COND_VALUE
            if [ -n "$COND_VALUE" ]; then
                break
            else
                left_text "${RED}Value cannot be empty. Try again.${RESET}"
            fi
        done
    fi
else
    left_text "${YELLOW}Choose condition column:${RESET}"
    for ((i=0; i<${#col_names[@]}; i++)); do
        left_text "$((i+1))) ${col_names[i]}"
    done

    while true; do
        cond_col=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Column number: " "int")
        if [[ "$cond_col" -ge 1 && "$cond_col" -le "${#col_names[@]}" ]]; then
            break
        else
            left_text "${RED}Invalid column number. Please choose a valid column.${RESET}"
        fi
    done

    COND_TYPE="${col_types[$((cond_col-1))]}"

    # =========================
    # Condition values
    # =========================
    echo
    if is_numeric "$COND_TYPE"; then
        # For primary key, enforce single value (no range)
        if [ "$cond_col" -eq "$pk" ]; then
            left_text "${YELLOW}ID filter (single value only):${RESET}"
        else
            left_text "${YELLOW}Numeric filter:${RESET}"
        fi
        
        while true; do
            START_VAL=$(get_valid_input "$(printf '%*s' $LEFT_PAD '')Start value: " "$COND_TYPE")
            
            if [ "$cond_col" -eq "$pk" ]; then
                # Primary key: no range, just single value
                END_VAL="$START_VAL"
                break
            else
                # Non-primary key: allow range
                read -p "$(printf '%*s' $LEFT_PAD '')End value (press Enter for single value): " END_VAL
                [ -z "$END_VAL" ] && END_VAL="$START_VAL"

                if [[ "$START_VAL" =~ ^-?[0-9]+$ && "$END_VAL" =~ ^-?[0-9]+$ ]]; then
                    # Ensure start <= end
                    cmp_ok=$(awk -v s="$START_VAL" -v e="$END_VAL" 'BEGIN{if((s+0) <= (e+0)) print 1; else print 0}')
                    if [ "$cmp_ok" -eq 1 ]; then
                        break
                    else
                        left_text "${RED}Start value cannot be greater than end value. Try again.${RESET}"
                    fi
                else
                    left_text "${RED}Invalid integer values. Try again.${RESET}"
                fi
            fi
        done
    else
        left_text "${YELLOW}String filter (exact match):${RESET}"
        while true; do
            read -p "$(printf '%*s' $LEFT_PAD '')Condition value: " COND_VALUE
            if [ -n "$COND_VALUE" ]; then
                break
            else
                left_text "${RED}Condition value cannot be empty. Try again.${RESET}"
            fi
        done
    fi
fi

# =========================
# Safe update (transaction)
# =========================
tmp_file=$(mktemp) || exit 1

# If updating primary key, ensure new value doesn't collide with another record
if [ "$update_col" -eq "$pk" ]; then
    # determine old pk value from condition
    if [ "$cond_col" -eq "$pk" ]; then
        if is_numeric "$COND_TYPE"; then
            old_pk="$START_VAL"
        else
            old_pk="$COND_VALUE"
        fi
    else
        old_pk=""
    fi

    if [ -n "$old_pk" ]; then
        if awk -F':' -v c="$pk" -v newv="$NEW_VALUE" -v oldv="$old_pk" '($c==newv && $c!=oldv){found=1; exit} END{if(found) exit 0; exit 1}' "$data_file"; then
            left_text "${RED}Error: Another record already uses the primary key value '$NEW_VALUE'. Update aborted.${RESET}"
            echo
            read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
            exit 1
        fi
    fi
fi

if is_numeric "$COND_TYPE"; then
    awk -F':' -v OFS=':' \
        -v uc="$update_col" \
        -v cv="$cond_col" \
        -v nv="$NEW_VALUE" \
        -v s="$START_VAL" \
        -v e="$END_VAL" '
        {
            if (($cv+0) >= (s+0) && ($cv+0) <= (e+0)) {
                $uc = nv
            }
            print
        }
    ' "$data_file" > "$tmp_file" || {
        rm -f "$tmp_file"
        echo -e "${RED}Update failed.${RESET}"
        exit 1
    }
else
    awk -F':' -v OFS=':' \
        -v uc="$update_col" \
        -v cv="$cond_col" \
        -v nv="$NEW_VALUE" \
        -v cond="$COND_VALUE" '
        {
            if ($cv == cond) {
                $uc = nv
            }
            print
        }
    ' "$data_file" > "$tmp_file" || {
        rm -f "$tmp_file"
        echo -e "${RED}Update failed.${RESET}"
        exit 1
    }
fi

# =========================
# Commit
# =========================
mv "$tmp_file" "$data_file"

echo
left_text "${GREEN}Update completed successfully.${RESET}"
echo
read -p "$(printf '%*s' $LEFT_PAD)Press Enter to return to Table Menu..."
exit 0
