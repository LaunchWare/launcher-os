#!/usr/bin/env bash
# Barrel file for bootstrap functions - orchestrates all installations

set -euo pipefail

# Get the directory of this script
BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities (assume lib is sibling to bootstrap)
source "$(dirname "$BOOTSTRAP_DIR")/lib/index.sh"

# Source all bootstrap modules
source "$BOOTSTRAP_DIR/gum.sh"
source "$BOOTSTRAP_DIR/aur.sh"
source "$BOOTSTRAP_DIR/hyprland.sh"
source "$BOOTSTRAP_DIR/fonts.sh"
source "$BOOTSTRAP_DIR/apps.sh"
source "$BOOTSTRAP_DIR/tools.sh"
source "$BOOTSTRAP_DIR/ssb.sh"

# Main bootstrap orchestrator function
run_bootstrap_installation() {
    log_section "🚀 Hyprland Base Setup - Bootstrap Installation"

    # Install gum first for enhanced UI throughout bootstrap
    if ! bootstrap_gum; then
        log_error "Failed to install gum - continuing with basic UI"
    fi

    # Install AUR helper for AUR packages
    if ! bootstrap_aur; then
        log_error "Failed to install AUR helper"
        return 1
    fi

    # Core system installation
    if ! bootstrap_hyprland; then
        log_error "Failed to install Hyprland"
        return 1
    fi

    # Install fonts
    if ! bootstrap_fonts; then
        log_error "Failed to install fonts"
        return 1
    fi

    # Install applications
    if ! bootstrap_apps; then
        log_error "Failed to install applications"
        return 1
    fi

    # Install desktop tools
    if ! bootstrap_tools; then
        log_error "Failed to install desktop tools"
        return 1
    fi

    # Install site-specific browsers
    if ! bootstrap_ssb; then
        log_error "Failed to install site-specific browsers"
        return 1
    fi

    log_section "✅ Bootstrap Installation Complete"
    log_success "Hyprland base setup has been installed successfully!"
    log_info "You can now log out and select Hyprland from your display manager."

    return 0
}

# Export main directory for other scripts
export BOOTSTRAP_DIR