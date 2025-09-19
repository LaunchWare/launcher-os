#!/usr/bin/env bash
# Install AUR helper (yay) for AUR packages

bootstrap_aur() {
    log_section "Installing AUR Helper (yay)"

    # Check if yay is already installed
    if has_command yay; then
        log_success "yay already installed"
        return 0
    fi

    log_progress "Installing yay AUR helper..."

    # Install base-devel and git (required for building AUR packages)
    run_command "sudo pacman -S --noconfirm base-devel git" \
        "Failed to install build dependencies"

    # Clone and build yay
    local temp_dir="/tmp/yay-install"
    rm -rf "$temp_dir"

    log_progress "Cloning yay repository..."
    run_command "git clone https://aur.archlinux.org/yay.git $temp_dir" \
        "Failed to clone yay repository"

    log_progress "Building and installing yay..."
    (
        cd "$temp_dir"
        run_command "makepkg -si --noconfirm" \
            "Failed to build and install yay"
    )

    # Clean up
    rm -rf "$temp_dir"

    # Verify installation
    if has_command yay; then
        log_success "yay installed successfully"
        return 0
    else
        log_error "yay installation failed"
        return 1
    fi
}