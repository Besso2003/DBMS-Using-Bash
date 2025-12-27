#!/bin/bash

db_path="$1"   # the path to the selected database

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

while true; do
    clear
    echo -e "${BLUE}==================== TABLE MENU ====================${NC}"
    echo -e "${YELLOW}1)${NC} Create Table"
    echo -e "${YELLOW}2)${NC} List Tables"
    echo -e "${YELLOW}3)${NC} Drop Table"
    echo -e "${YELLOW}4)${NC} Insert Into Table"
    echo -e "${YELLOW}5)${NC} Select From Table"
    echo -e "${YELLOW}6)${NC} Delete From Table"
    echo -e "${YELLOW}7)${NC} Update Table"
    echo -e "${YELLOW}8)${NC} Back to Main Menu"
    echo -e "${BLUE}====================================================${NC}"

    read -p "Enter your choice [1-8]: " choice

    case $choice in
        1)
            clear
            ./scripts/create_table.sh "$db_path"
            ;;
        2)
            echo "List Tables (to be implemented)"
            ;;
        3)
            echo "Drop Table (to be implemented)"
            ;;
        4)
            ./scripts/insertion.sh "$db_path"
            ;;
        5)
            echo "Select From Table (to be implemented)"
            ;;
        6)
            clear
            ./scripts/delete_from_table.sh "$db_path"
            ;;
        7)
            echo "Update Table (to be implemented)"
            ;;
        8)
            clear
            echo "Returning to Main Menu..."
            sleep 1
            clear
            break
            ;;
        *)
            echo "Invalid Choice! Please Enter [1-8]."
            ;;
    esac
done
