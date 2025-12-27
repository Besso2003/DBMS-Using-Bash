#!/bin/bash

# =========================
# Input validation
# =========================
if [ $# -lt 1 ] || [ $# -gt 4 ]; then
    echo "Usage:"
    echo "  $0 <table.db>"
    echo "  $0 <table.db> <column_name> <value>"
    echo "  $0 <table.db> <column_name> <start> <end>"
    exit 1
fi

TABLE="$1"
COL_NAME="$2"
ARG1="$3"
ARG2="$4"

# =========================
# File validation
# =========================
if [ ! -f "$TABLE" ]; then
    echo "Error: table file not found"
    exit 1
fi

META="${TABLE%.db}.meta"

if [ ! -f "$META" ]; then
    echo "Error: meta file not found"
    exit 1
fi

# =========================
# Read meta values
# =========================
PK_COL=$(awk -F'=' '$1=="pk"{print $2}' "$META")
COL_COUNT=$(awk -F'=' '$1=="columns"{print $2}' "$META")
NAMES=$(awk -F'=' '$1=="names"{print $2}' "$META")
TYPES=$(awk -F'=' '$1=="types"{print $2}' "$META")

# =========================
# Validate PK
# =========================
if ! [[ "$PK_COL" =~ ^[0-9]+$ ]]; then
    echo "Error: invalid or missing pk in meta file"
    exit 1
fi


# =========================
# Selection logic
# =========================
if [ -z "$COL_NAME" ]; then
    # No filtering → select all
    awk -F':' -v cols="$COL_COUNT" '
    (cols=="" || NF==cols)
    ' "$TABLE" |
    sort -t':' -k"${PK_COL},${PK_COL}"n |
    {
        echo "$NAMES"
        cat
    }
    exit 0
fi

# Resolve column index from name
COL_INDEX=$(echo "$NAMES" | awk -F':' -v name="$COL_NAME" '{for(i=1;i<=NF;i++) if($i==name){print i; exit}}')
if [ -z "$COL_INDEX" ]; then
    echo "Error: column '$COL_NAME' not found in meta"
    exit 1
fi

# Determine column type
COL_TYPE=$(echo "$TYPES" | awk -F':' -v idx="$COL_INDEX" '{for(i=1;i<=NF;i++) if(i==idx){print $i; exit}}')

is_numeric() {
    case "$1" in
        int|float|double) return 0 ;;
        *) return 1 ;;
    esac
}

if is_numeric "$COL_TYPE"; then
    # Numeric column: allow single value or range
    if [ -z "$ARG1" ]; then
        echo "Error: missing numeric value for column '$COL_NAME'"
        exit 1
    fi
    START_VAL="$ARG1"
    if [ -z "$ARG2" ]; then
        END_VAL="$START_VAL"
    else
        END_VAL="$ARG2"
    fi

    num_re='^-?[0-9]+(\.[0-9]+)?$'
    if ! [[ "$START_VAL" =~ $num_re && "$END_VAL" =~ $num_re ]]; then
        echo "Error: numeric filter values must be numbers"
        exit 1
    fi

    # Ensure start <= end (numeric comparison using awk)
    cmp_ok=$(awk -v s="$START_VAL" -v e="$END_VAL" 'BEGIN{if((s+0) <= (e+0)) print 1; else print 0}')
    if [ "$cmp_ok" -ne 1 ]; then
        echo "Error: start greater than end"
        exit 1
    fi

    awk -F':' -v c="$COL_INDEX" -v s="$START_VAL" -v e="$END_VAL" -v cols="$COL_COUNT" '
    (cols=="" || NF==cols) && ($c+0) >= (s+0) && ($c+0) <= (e+0)
    ' "$TABLE" |
    sort -t':' -k"${PK_COL},${PK_COL}"n |
    {
        echo "$NAMES"
        cat
    }
    exit 0
else
    # String column: only exact match allowed
    if [ -z "$ARG1" ] || [ -n "$ARG2" ]; then
        echo "Error: string column requires exactly one value to match"
        exit 1
    fi
    VAL="$ARG1"
    awk -F':' -v c="$COL_INDEX" -v v="$VAL" -v cols="$COL_COUNT" '
    (cols=="" || NF==cols) && $c == v
    ' "$TABLE" |
    sort -t':' -k"${PK_COL},${PK_COL}"n |
    {
        echo "$NAMES"
        cat
    }
    exit 0
fi
