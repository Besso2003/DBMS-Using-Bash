#!/bin/bash

mkdir -p databases

# Use SCRIPT_DIR from selector_mode.sh or default to CLI
SCRIPT_DIR=${SCRIPT_DIR:-scripts/cli}

# Source shared UI helpers
source "$SCRIPT_DIR/ui.sh"

while true; do
    clear
    echo
    echo
    center_text "$(echo -e "${CYAN}-------------------------------------------------- MAIN MENU --------------------------------------------------${RESET}")"
    echo
    center_text "$(echo -e "${YELLOW}1) Create Database${RESET}")"
    echo
    center_text "$(echo -e "${YELLOW}2) List Database${RESET}")"
    echo
    center_text "$(echo -e "${YELLOW}3) Connect To Database${RESET}")"
    echo
    center_text "$(echo -e "${YELLOW}4) Drop Database${RESET}")"
    echo
    center_text "$(echo -e "${RED}5) Exit${RESET}")"
    echo
    center_text "$(echo -e "${CYAN}----------------------------------------------------------------------------------------------------------------${RESET}")"
    echo

    read -p "Enter Your Choice [1-5]: " choice
    echo

    case $choice in
        1)
           "$SCRIPT_DIR/create_database.sh"
           ;;
        2)
           "$SCRIPT_DIR/list_database.sh"
           ;;
        3)
           read -p "Enter database name to connect: " db_name
           "$SCRIPT_DIR/connect_database.sh" "$db_name"
           ;;
        4)
           read -p "Enter database name to drop: " db_name
           "$SCRIPT_DIR/drop_database.sh" "$db_name"
           ;;
        5)
           clear
           echo -e "${RED}Exiting...${RESET}"
           sleep 1
           clear
           exit 0
           ;;
        *)
           echo -e "${RED}Invalid Choice! Please enter [1-5].${RESET}"
           ;;
    esac

    # Only pause if the choice was not 3 (connect to DB) or if Table Menu returned
    if [[ "$choice" -ne 3 ]]; then
        echo
        read -p "Press Enter to continue..." dummy
    fi
done
