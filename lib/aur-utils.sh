#!/usr/bin/env bash
# AUR package utilities

# Install packages from AUR using yay
install_aur_packages() {
    local packages="$1"
    local description="${2:-AUR packages}"

    if [[ -z "$packages" ]]; then
        log_warning "No AUR packages to install"
        return 0
    fi

    # Check if yay is available
    if ! has_command yay; then
        log_error "yay not available - cannot install AUR packages"
        return 1
    fi

    log_progress "Installing $description from AUR..."
    log_info "AUR packages: $packages"

    run_command "yay -S --noconfirm $packages" \
        "Failed to install $description from AUR"

    log_success "$description installed successfully from AUR"
    return 0
}

# Install packages from AUR package list file
install_aur_from_package_list() {
    local file="$1"
    local description="${2:-AUR packages from $file}"

    if [[ ! -f "$file" ]]; then
        log_warning "AUR package list file not found: $file"
        return 0
    fi

    local packages
    packages=$(read_package_list "$file")

    install_aur_packages "$packages" "$description"
}