#!/bin/bash

# =========================
# Drop Table (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"
TABLES_PATH="$DB_PATH/tables"

LEFT_PAD=20
source "$SCRIPT_DIR/ui.sh"

echo

# Header
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
center_text "${WHITE}${BOLD}                  DROP TABLE${RESET}"
center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
echo

# Validate database path
if [ -z "$DB_PATH" ] || [ ! -d "$DB_PATH" ]; then
    left_text "${RED}${BOLD}Error:${RESET} Database path missing or does not exist." 
    echo
    left_text "Press Enter to return to Table Menu..."
    read -r
    return 1 2>/dev/null || exit 1
fi

# Check for tables
if [ ! -d "$TABLES_PATH" ] || [ -z "$(ls -A "$TABLES_PATH"/*.meta 2>/dev/null)" ]; then
    left_text "${YELLOW}${BOLD}No tables found in this database.${RESET}"
    echo
    left_prompt "Press Enter to return to Table Menu..."
    read -r
    return 0 2>/dev/null || exit 0
fi

# Show tables (brief list)
count=1
for meta_file in "$TABLES_PATH"/*.meta; do
    [ -f "$meta_file" ] || continue
    table_name=$(basename "$meta_file" .meta)
    printf -v num "%2d" "$count"
    left_text "${WHITE}${BOLD}$num) $table_name${RESET}"
    ((count++))
done

echo

# Prompt for table name to drop
while true; do
    left_prompt "${WHITE}${BOLD}Enter table name to drop: ${RESET}"
    read table_name

    if [ -z "$table_name" ]; then
        left_text "${RED}Error:${RESET} Table name cannot be empty."
        continue
    fi

    meta_file="$TABLES_PATH/$table_name.meta"
    data_file="$TABLES_PATH/$table_name.db"

    if [ ! -f "$meta_file" ]; then
        left_text "${RED}Error:${RESET} Table '$table_name' does not exist." 
        continue
    fi

    break
done

echo
left_text "${YELLOW}DANGEROUS ACTION:${RESET} This will permanently delete table '$table_name' and its data."
left_text "Type the table name exactly to confirm deletion, or type CANCEL to abort."
echo

while true; do
    left_prompt "${WHITE}${BOLD}${table_name} > ${RESET}"
    read -r confirm
    confirm=$(echo "$confirm" | xargs)

    if [ "$confirm" = "CANCEL" ]; then
        echo
        left_text "${GREEN}Deletion aborted.${RESET}"
        echo
        left_prompt "Press Enter to return to Table Menu..."
        read -r
        return 0 2>/dev/null || exit 0
    fi

    if [ "$confirm" = "$table_name" ]; then
        if rm -f -- "$meta_file" "$data_file"; then
            left_text "${GREEN}Table '$table_name' deleted successfully.${RESET}"
            echo
            left_prompt "Press Enter to return to Table Menu..."
            read -r
            return 0 2>/dev/null || exit 0
        else
            left_text "${RED}Error: Failed to delete table '$table_name'.${RESET}"
            return 1 2>/dev/null || exit 1
        fi
    else
        left_text "${RED}Names do not match. Type the table name to confirm, or CANCEL to abort.${RESET}"
    fi
done
