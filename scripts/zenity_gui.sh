#!/bin/bash

gui_input() {
    if $GUI_AVAILABLE; then
        zenity --entry --title="$1" --text="$2"
    else
        read -p "$2 " value
        echo "$value"
    fi
}

gui_info() {
    if $GUI_AVAILABLE; then
        zenity --info --title="$1" --text="$2"
    else
        echo "$2"
        sleep 1
    fi
}

gui_error() {
    if $GUI_AVAILABLE; then
        zenity --error --title="$1" --text="$2"
    else
        echo "ERROR: $2" >&2
    fi
}

gui_confirm() {
    if $GUI_AVAILABLE; then
        zenity --question --title="$1" --text="$2"
    else
        read -p "$2 [y/N]: " ans
        [[ "$ans" =~ ^[Yy]$ ]]
    fi
}

gui_menu() {
    if $GUI_AVAILABLE; then
        zenity --list --title="$1" --width=500 --height=500 --column="ID" --column="Action" "${@:2}"
    else
        echo "$1"
        shift
        while [ "$#" -gt 0 ]; do
            echo "$1) $2"
            shift 2
        done
        read -p "Choose: " choice
        echo "$choice"
    fi
}
