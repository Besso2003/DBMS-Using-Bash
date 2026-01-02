#!/bin/bash

# =========================
# Table Menu (CLI)
# =========================

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

DB_PATH="$1"   # selected database path

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$SCRIPT_DIR/ui.sh"

while true; do
    clear
    echo

    # Header
    center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
    center_text "${WHITE}${BOLD}                   TABLE MENU${RESET}"
    center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
    echo

    # Menu items
    left_text "${WHITE}${BOLD}1) Create Table${RESET}"
    left_text "${WHITE}${BOLD}2) List Tables${RESET}"
    left_text "${WHITE}${BOLD}3) Drop Table${RESET}"
    left_text "${WHITE}${BOLD}4) Insert Into Table${RESET}"
    left_text "${WHITE}${BOLD}5) Select From Table${RESET}"
    left_text "${WHITE}${BOLD}6) Delete From Table${RESET}"
    left_text "${WHITE}${BOLD}7) Update Table${RESET}"
    echo
    left_text "${RED}${BOLD}8) Back to Main Menu${RESET}"

    echo
    center_text "${CYAN}${BOLD}=============================================================================================================================${RESET}"
    echo

    printf "%*sEnter your choice [1-8]: " "$LEFT_PAD" ""
    read choice

    case $choice in
        1)
            clear
            "$SCRIPT_DIR/create_table.sh" "$DB_PATH"
            ;;
        2)
            clear
            "$SCRIPT_DIR/list_tables.sh" "$DB_PATH"
            ;;
        3)
            clear
            "$SCRIPT_DIR/drop_table.sh" "$DB_PATH"
            ;;
        4)
            clear
            "$SCRIPT_DIR/insertion.sh" "$DB_PATH"
            ;;
        5)
            clear
            "$SCRIPT_DIR/select.sh" "$DB_PATH"
            ;;
        6)
            clear
            "$SCRIPT_DIR/delete_from_table.sh" "$DB_PATH"
            ;;
        7)
            clear
            "$SCRIPT_DIR/update.sh" "$DB_PATH"
            ;;
        8)
            clear
            echo -e "${YELLOW}Returning to Main Menu...${RESET}"
            sleep 1
            break
            ;;
        *)
            left_text "${RED}Invalid Choice! Please Enter [1-8].${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
