#!/usr/bin/env bash
# Install gum for enhanced UI (first bootstrap step)

bootstrap_gum() {
    log_section "Installing Gum"

    # Check if gum is already installed
    if has_command gum; then
        log_success "Gum already installed"
        return 0
    fi

    log_progress "Installing gum from official repositories..."

    # Install gum via pacman
    if pacman -Si gum >/dev/null 2>&1; then
        run_command "sudo pacman -S --noconfirm gum" "Failed to install gum via pacman"
    else
        log_error "Gum not available in official repos"
        log_info "Please install gum via AUR first: yay -S gum"
        return 1
    fi

    # Verify installation
    if has_command gum; then
        log_success "Gum installed successfully"
        return 0
    else
        log_error "Gum installation failed"
        return 1
    fi
}