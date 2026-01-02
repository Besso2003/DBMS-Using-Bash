#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
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
                echo
                echo -e "${RED}Dialog is not installed.${RESET}"
                echo
                echo -e "${GREEN}You can install it using:${RESET}"
                echo -e "  sudo apt install dialog    # Debian/Ubuntu"
                echo -e "  sudo yum install dialog    # RedHat/CentOS/Fedora"
                echo -e "  sudo dnf install dialog    # Fedora"
                echo -e "  brew install dialog        # macOS (Homebrew)"
                echo
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
