#!/bin/bash

db_path="$1"
tables_path="$db_path/tables"

# Load dialog or fallback UI
if command -v dialog >/dev/null 2>&1; then
    source "scripts/dialog_ui.sh"
else
    source "scripts/ui.sh"
fi

# Build tables list message
msg=""

if [ ! -d "$tables_path" ] || [ -z "$(ls -A "$tables_path"/*.meta 2>/dev/null)" ]; then
    msg="No tables found."
else
    count=1
    for meta_file in "$tables_path"/*.meta; do
        [ -f "$meta_file" ] || continue
        table_name=$(basename "$meta_file" .meta)
        msg+="$count) $table_name\n"
        ((count++))
    done
fi

# Show tables in dialog
dialog --title "AVAILABLE TABLES" \
       --msgbox "$msg" 15 50

clear
