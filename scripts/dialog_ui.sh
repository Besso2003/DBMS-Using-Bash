#!/bin/bash

# Menu
gui_menu() {
    local title="$1"
    shift
    dialog --clear --title "$title" --menu "Choose an option:" 15 50 6 "$@"
}

# Info
gui_info() {
    local title="$1"
    local msg="$2"
    dialog --title "$title" --msgbox "$msg" 10 50
}


# Error message
gui_error() {
    local title="$1"
    local msg="$2"
    dialog --title "$title" --msgbox "$msg" 10 50
}

gui_input() {
    local title="$1"
    local prompt="$2"
    local tmpfile
    tmpfile=$(mktemp)
    dialog --title "$title" --inputbox "$prompt" 10 50 2> "$tmpfile"
    local status=$?
    [ $status -eq 0 ] && cat "$tmpfile"
    rm -f "$tmpfile"
    return $status
}
