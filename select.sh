#!/bin/bash

# =========================
# Argument validation
# =========================
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage:"
    echo "  $0 <table.db> <pk_value>"
    echo "  $0 <table.db> <pk_start> <pk_end>"
    exit 1
fi

TABLE="$1"
START="$2"
END="$3"

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
TYPES=$(awk -F'=' '$1=="types"{print $2}' "$META")

# =========================
# Validate PK
# =========================
if ! [[ "$PK_COL" =~ ^[0-9]+$ ]]; then
    echo "Error: invalid or missing pk in meta file"
    exit 1
fi

# =========================
# Normalize range
# =========================
if [ -z "$END" ]; then
    END="$START"
fi

if ! [[ "$START" =~ ^[0-9]+$ && "$END" =~ ^[0-9]+$ ]]; then
    echo "Error: PK values must be numeric"
    exit 1
fi

if [ "$START" -gt "$END" ]; then
    echo "Error: start PK greater than end PK"
    exit 1
fi

# =========================
# Extract header
# =========================
HEADER=$(head -n 1 "$TABLE")

# =========================
# Selection + Sorting
# =========================
awk -F':' -v pk="$PK_COL" -v s="$START" -v e="$END" -v cols="$COL_COUNT" '
NR==1 { next }

# optional column-count validation
(cols == "" || NF == cols) && $pk >= s && $pk <= e
' "$TABLE" |
sort -t':' -k"${PK_COL},${PK_COL}"n |
{
    echo "$HEADER"
    cat
}

