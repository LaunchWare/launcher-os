#!/usr/bin/env bash
# Package utilities for reading and installing from package lists

# Read packages from a file, ignoring comments and empty lines
read_package_list() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "Package list file not found: $file"
        return 1
    fi

    # Read file, strip comments and empty lines
    grep -v '^#' "$file" | grep -v '^[[:space:]]*$' | tr '\n' ' '
}

# Install packages from a package list file
install_from_package_list() {
    local file="$1"
    local description="${2:-packages from $file}"

    log_progress "Installing $description..."

    local packages
    packages=$(read_package_list "$file")

    if [[ -z "$packages" ]]; then
        log_warning "No packages found in $file"
        return 0
    fi

    log_info "Packages to install: $packages"

    run_command "sudo pacman -S --noconfirm $packages" \
        "Failed to install $description"

    log_success "$description installed successfully"
    return 0
}