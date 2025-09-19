#!/usr/bin/env bash
# Common utility functions

# Check if a command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed via pacman
has_package() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if user has sudo access
has_sudo() {
    sudo -v >/dev/null 2>&1
}

# Get OS information
get_os_info() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

# Check if OS is Arch-based
is_arch_based() {
    local os_id
    os_id=$(get_os_info)
    [[ "$os_id" == "arch" ]] || [[ "$ID_LIKE" == *"arch"* ]]
}

# Run command with error handling
run_command() {
    local cmd="$1"
    local error_msg="${2:-Command failed: $cmd}"

    if ! eval "$cmd"; then
        error_exit "$error_msg"
    fi
}

# Check if file exists and is readable
file_readable() {
    [[ -f "$1" && -r "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    [[ -d "$1" ]] || mkdir -p "$1"
}