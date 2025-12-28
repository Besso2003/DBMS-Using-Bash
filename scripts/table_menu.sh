#!/bin/bash

db_path="$1"   # selected database path

# prefer script-local padding, ui.sh will provide helpers
LEFT_PAD=10
source "$(dirname "$0")/ui.sh"


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
            ./scripts/create_table.sh "$db_path"
            ;;
        2)
            clear
            ./scripts/list_tables.sh "$db_path"
            ;;
        3)
            clear
            ./scripts/drop_table.sh "$db_path"
            ;;
        4)
            clear
            ./scripts/insertion.sh "$db_path"
            ;;
        5)
            clear
            ./scripts/select.sh "$db_path"
            ;;
        6)
            clear
            ./scripts/delete_from_table.sh "$db_path"
            ;;
        7)
            clear
            ./scripts/update.sh "$db_path"
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
