# Shared UI helpers for DBMS scripts

# Colors (do not override if already set)
: ${CYAN:="\033[36m"}
: ${WHITE:="\033[97m"}
: ${YELLOW:="\033[33m"}
: ${RED:="\033[31m"}
: ${GREEN:="\033[32m"}
: ${BOLD:="\033[1m"}
: ${RESET:="\033[0m"}

# Default padding (scripts may override before sourcing)
: ${LEFT_PAD:=10}

# Center text
center_text() {
    local text="$1"
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (term_width - ${#text}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$(echo -e "$text")"
}

# Left padded text
left_text() {
    printf "%*s%s\n" "$LEFT_PAD" "" "$(echo -e "$1")"
}

# Left prompt (no newline)
left_prompt() {
    printf "%*s%s" "$LEFT_PAD" "" "$(echo -e "$1")"
}
