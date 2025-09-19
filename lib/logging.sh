#!/usr/bin/env bash
# Logging and output functions

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

# Check if gum is available
_has_gum() {
    command -v gum >/dev/null 2>&1
}

# Error handler
log_error() {
    if _has_gum; then
        gum style --foreground="$CATPPUCCIN_RED" --bold "ERROR: $1"
    else
        echo -e "${ANSI_RED}ERROR: $1${ANSI_NC}" >&2
    fi
}

# Warning handler
log_warning() {
    if _has_gum; then
        gum style --foreground="$CATPPUCCIN_YELLOW" "WARNING: $1"
    else
        echo -e "${ANSI_YELLOW}WARNING: $1${ANSI_NC}"
    fi
}

# Success handler
log_success() {
    if _has_gum; then
        gum style --foreground="$CATPPUCCIN_GREEN" "✓ $1"
    else
        echo -e "${ANSI_GREEN}✓ $1${ANSI_NC}"
    fi
}

# Info handler
log_info() {
    if _has_gum; then
        gum style --foreground="$CATPPUCCIN_BLUE" "$1"
    else
        echo -e "${ANSI_BLUE}$1${ANSI_NC}"
    fi
}

# Progress handler
log_progress() {
    if _has_gum; then
        gum style --foreground="$CATPPUCCIN_TEAL" "→ $1"
    else
        echo -e "${ANSI_CYAN}→ $1${ANSI_NC}"
    fi
}

# Section header
log_section() {
    if _has_gum; then
        gum style --border="rounded" --border-foreground="$CATPPUCCIN_LAVENDER" --padding="0 1" "$1"
    else
        echo -e "\n${ANSI_BOLD}${ANSI_BLUE}=== $1 ===${ANSI_NC}\n"
    fi
}

# Confirmation prompt
confirm() {
    local message="$1"
    if _has_gum; then
        gum confirm "$message"
    else
        read -p "$message (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Error exit
error_exit() {
    log_error "$1"
    exit 1
}