#!/usr/bin/env bash
# Check if running Arch Linux or Arch-based distribution

precheck_arch() {
    log_progress "Checking if running Arch Linux..."

    if ! is_arch_based; then
        log_error "This script requires Arch Linux or an Arch-based distribution"
        log_info "Detected OS: $(get_os_info)"
        return 1
    fi

    log_success "Running Arch Linux (or Arch-based distribution)"
    return 0
}