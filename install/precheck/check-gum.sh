#!/usr/bin/env bash
# Check that gum can be installed (readonly validation)

precheck_gum() {
    log_progress "Checking gum availability..."

    # Check if gum is already installed
    if has_command gum; then
        log_success "Gum already installed"
        return 0
    fi

    # Check if gum can be installed via pacman
    if pacman -Si gum >/dev/null 2>&1; then
        log_success "Gum available in official repositories"
        return 0
    else
        log_error "Gum not available in official repos"
        log_info "This setup requires gum for consistent UI"
        log_info "Please install gum via AUR first: paru -S gum"
        return 1
    fi
}