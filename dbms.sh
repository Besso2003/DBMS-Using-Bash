#!/bin/bash

mkdir -p databases

# Colors
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to center text
center_text() {
    local term_width=$(tput cols)
    local text="$1"
    local padding=$(( (term_width - ${#text}) / 2 ))
    printf "%*s%s\n" $padding "" "$text"
}

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
           ./scripts/create_database.sh
           ;;
        2)
           ./scripts/list_database.sh
           ;;
        3)
           read -p "Enter database name to connect: " db_name
           ./scripts/connect_database.sh "$db_name"
           ;;
        4)
           read -p "Enter database name to drop: " db_name
           ./scripts/drop_database.sh "$db_name"
           ;;
        5)
           echo -e "${RED}Exiting...${RESET}"
           exit 0
           ;;
        *)
           echo -e "${RED}Invalid Choice! Please enter [1-5].${RESET}"
           ;;
    esac

    echo
    read -p "Press Enter to continue..." dummy
done