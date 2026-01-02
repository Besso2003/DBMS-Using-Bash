#!/bin/bash

# ==========================
# List Tables (GUI)
# ==========================

db_path="$1"
tables_path="$db_path/tables"

SCRIPT_DIR=${SCRIPT_DIR:-scripts/gui}
source "$SCRIPT_DIR/dialog_ui.sh"

# --------------------------
# Build tables list message
# --------------------------
msg=""

if [ ! -d "$tables_path" ] || ! ls "$tables_path"/*.meta >/dev/null 2>&1; then
    msg="No tables found."
else
    count=1
    for meta_file in "$tables_path"/*.meta; do
        table_name=$(basename "$meta_file" .meta)
        msg+="$count) $table_name\n"
        ((count++))
    done
fi

# --------------------------
# Show tables
# --------------------------
dialog --clear \
       --title "AVAILABLE TABLES" \
       --msgbox "$(echo -e "$msg")" 15 50

clear
exit 0
