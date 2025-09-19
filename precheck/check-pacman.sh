#!/usr/bin/env bash
# Check pacman availability and functionality

precheck_pacman() {
    log_progress "Checking pacman availability..."

    # Check if pacman command exists
    if ! has_command pacman; then
        log_error "Pacman package manager not found"
        log_info "Are you running Arch Linux?"
        return 1
    fi

    log_success "Pacman command available"

    # Test basic pacman functionality
    log_progress "Testing pacman functionality..."

    if ! pacman -Q pacman >/dev/null 2>&1; then
        log_error "Pacman is not functioning properly"
        log_info "Try running: sudo pacman -Sy"
        return 1
    fi

    log_success "Pacman package manager functional"
    return 0
}