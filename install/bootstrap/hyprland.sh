#!/usr/bin/env bash
# Install Hyprland compositor and core dependencies

# Enable multilib repository for 32-bit packages
enable_multilib_repository() {
    log_progress "Enabling multilib repository..."

    # Check if multilib is already enabled
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_success "Multilib repository already enabled"
        return 0
    fi

    # Enable multilib repository
    if ! sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; then
        log_error "Failed to enable multilib repository"
        return 1
    fi

    # Update package database
    if ! run_command "sudo pacman -Sy" "Failed to update package database"; then
        return 1
    fi

    log_success "Multilib repository enabled successfully"
    return 0
}

bootstrap_hyprland() {
    log_section "Installing Hyprland"

    # Get bootstrap directory
    local bootstrap_dir="$(dirname "${BASH_SOURCE[0]}")"

    # Enable multilib repository for 32-bit packages
    enable_multilib_repository

    # Check if Hyprland is already installed
    if has_package hyprland; then
        log_success "Hyprland already installed"
    else
        # Install core Hyprland packages
        install_from_package_list "$bootstrap_dir/packages/hyprland-core.txt" \
            "Hyprland core packages"
    fi

    # Install essential system services
    install_from_package_list "$bootstrap_dir/packages/system-services.txt" \
        "system services"

    # Install AUR system packages
    if [[ -f "$bootstrap_dir/packages/aur-system.txt" ]]; then
        install_aur_packages "$bootstrap_dir/packages/aur-system.txt" \
            "AUR system packages"
    fi

    # Enable user services
    log_progress "Enabling user services..."

    # Enable PipeWire services for current user
    systemctl --user enable pipewire.service >/dev/null 2>&1 || true
    systemctl --user enable wireplumber.service >/dev/null 2>&1 || true

    log_success "Hyprland installation complete"
    return 0
}