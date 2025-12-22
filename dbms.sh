#! /bin/bash

mkdir -p databases

while true; do
    echo
    echo "------ MAIN MENU ------"
    echo "1) Create Database"
    echo "2) List Database"
    echo "3) Connect To Database"
    echo "4) Drop Database"
    echo "5) Exit"
    echo "-----------------------"

    read -p "Enter Your Choice [1-5]: " choice

    case $choice in
        1)
           read -p "Enter database name to create: " db_name
           ./scripts/create_database.sh "$db_name"
           ;;
        2)
           ./scripts/list_database.sh
           ;;
        3)
           read -p "Enter datbase name to connect: " db_name
           ./scripts/connect_database.sh "$db_name"
           ;;
        4)
           echo "Drop database need to be implement yet!!!"
           ;;
        5)
           echo "Exiting..."
           exit 0
           ;;
        *)
           echo "Invalid Choice! Please enter [1-5]."
           ;;
    esac
done