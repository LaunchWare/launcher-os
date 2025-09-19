#!/usr/bin/env bash
# Check user context and sudo access

precheck_user() {
    log_progress "Checking user context..."

    # Check if not running as root
    if is_root; then
        log_error "Do not run this script as root"
        log_info "Please run as a regular user with sudo privileges"
        return 1
    fi

    log_success "Running as non-root user"

    # Check sudo access
    log_progress "Verifying sudo access..."

    # Check if user is in sudo/wheel group first
    if groups | grep -q '\bsudo\b\|\bwheel\b'; then
        log_success "User is in sudo/wheel group"
    else
        # Try actual sudo command
        log_info "Testing sudo access (may prompt for password)..."
        if ! has_sudo; then
            log_error "User does not have sudo privileges"
            log_info "Please ensure you can run 'sudo' commands"
            return 1
        fi
        log_success "Sudo access verified"
    fi
    return 0
}