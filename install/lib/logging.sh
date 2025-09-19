#!/usr/bin/env bash
# Logging and output functions - requires gum

# Catppuccin Mocha colors for gum
CATPPUCCIN_RED="#f38ba8"
CATPPUCCIN_GREEN="#a6e3a1"
CATPPUCCIN_YELLOW="#f9e2af"
CATPPUCCIN_BLUE="#89b4fa"
CATPPUCCIN_TEAL="#94e2d5"
CATPPUCCIN_LAVENDER="#b4befe"

# Check if gum is available - exit if not
if ! command -v gum >/dev/null 2>&1; then
    echo "ERROR: gum is required but not installed" >&2
    echo "Please install gum first: pacman -S gum" >&2
    exit 1
fi

# Error handler
log_error() {
    gum style --foreground="$CATPPUCCIN_RED" --bold "ERROR: $1" >&2
}

# Warning handler
log_warning() {
    gum style --foreground="$CATPPUCCIN_YELLOW" "WARNING: $1"
}

# Success handler
log_success() {
    gum style --foreground="$CATPPUCCIN_GREEN" "✓ $1"
}

# Info handler
log_info() {
    gum style --foreground="$CATPPUCCIN_BLUE" "$1"
}

# Progress handler
log_progress() {
    gum style --foreground="$CATPPUCCIN_TEAL" "→ $1"
}

# Section header
log_section() {
    gum style --border="rounded" --border-foreground="$CATPPUCCIN_LAVENDER" --padding="0 1" "$1"
}

# Confirmation prompt
confirm() {
    local message="$1"
    gum confirm "$message"
}

# Error exit
error_exit() {
    log_error "$1"
    exit 1
}