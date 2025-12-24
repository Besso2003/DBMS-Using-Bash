#!/bin/bash

db_path="$1"   # the path to the selected database

while true; do
    echo
    echo "------ TABLE MENU ------"
    echo "1) Create Table"
    echo "2) List Tables"
    echo "3) Drop Table"
    echo "4) Insert Into Table"
    echo "5) Select From Table"
    echo "6) Delete From Table"
    echo "7) Update Table"
    echo "8) Back to Main Menu"
    echo "------------------------"

    read -p "Enter your choice [1-8]: " choice

    case $choice in
        1)
            ./scripts/create_table.sh "$db_path"   # pass the correct db path
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
            echo "Delete from Table (to be implemented)"
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
