#!/usr/bin/env bash
# Install AUR helper (paru) for AUR packages

bootstrap_aur() {
    log_section "Installing AUR Helper (paru)"

    # Check if paru is already installed
    if has_command paru; then
        log_success "paru already installed"
        return 0
    fi

    log_progress "Installing paru AUR helper..."

    # Install base-devel and git (required for building AUR packages)
    run_command "sudo pacman -S --noconfirm base-devel git" \
        "Failed to install build dependencies"

    # Clone and build paru
    local temp_dir="/tmp/paru-install"
    rm -rf "$temp_dir"

    log_progress "Cloning paru repository..."
    run_command "git clone https://aur.archlinux.org/paru.git $temp_dir" \
        "Failed to clone paru repository"

    log_progress "Building and installing paru..."
    (
        cd "$temp_dir"
        run_command "makepkg -si --noconfirm" \
            "Failed to build and install paru"
    )

    # Clean up
    rm -rf "$temp_dir"

    # Verify installation
    if has_command paru; then
        log_success "paru installed successfully"
        return 0
    else
        log_error "paru installation failed"
        return 1
    fi
}

# Install AUR packages - supports both package names and manifest files
install_aur_packages() {
    local input="$1"
    local description="$2"

    # Check if paru is available
    if ! has_command paru; then
        log_error "paru not found - cannot install AUR packages"
        return 1
    fi

    local packages=""

    # Determine if input is a file or package name(s)
    if [[ -f "$input" ]]; then
        # It's a manifest file
        description="${description:-AUR packages from $(basename "$input")}"
        packages=$(read_package_list "$input")

        if [[ -z "$packages" ]]; then
            log_warning "No AUR packages found in $input"
            return 0
        fi
    else
        # It's package name(s)
        packages="$input"
        description="${description:-AUR packages}"
    fi

    log_progress "Installing $description..."
    log_info "AUR packages to install: $packages"

    run_command "paru -S --noconfirm $packages" \
        "Failed to install $description"

    log_success "$description installed successfully"
    return 0
}