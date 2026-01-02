#!/bin/bash

RED="\e[31m"
RESET="\e[0m"

# ==========================
# Selector Mode: CLI or GUI
# ==========================

while true; do
    clear
    echo "==============================="
    echo "     DBMS Interface Selector    "
    echo "==============================="
    echo "1) CLI (Text UI)"
    echo "2) GUI (Dialog)"
    echo "3) Exit"
    echo "==============================="

    read -p "Enter choice [1-3]: " mode

    case "$mode" in
        1)
            SCRIPT_DIR="scripts/cli"
            break
            ;;
        2)
            if ! command -v dialog >/dev/null 2>&1; then
                echo -e "${RED}Dialog is not installed.${RESET}"
                read -p "Press Enter to continue..."
                continue
            fi
            SCRIPT_DIR="scripts/gui"
            break
            ;;
        3)
            echo -e "${RED}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo
            echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${RESET}"
            read -p "Press Enter to try again..."
            ;;
    esac
done

export SCRIPT_DIR
"$SCRIPT_DIR/dbms.sh"
