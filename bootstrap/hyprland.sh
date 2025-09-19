#!/usr/bin/env bash
# Install Hyprland compositor and core dependencies

bootstrap_hyprland() {
    log_section "Installing Hyprland"

    # Get bootstrap directory
    local bootstrap_dir="$(dirname "${BASH_SOURCE[0]}")"

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

    # Enable user services
    log_progress "Enabling user services..."

    # Enable PipeWire services for current user
    systemctl --user enable pipewire.service >/dev/null 2>&1 || true
    systemctl --user enable wireplumber.service >/dev/null 2>&1 || true

    log_success "Hyprland installation complete"
    return 0
}