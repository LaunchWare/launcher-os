#!/usr/bin/env bash
# Copy launcher-os configuration files to user config

config_copy_user_config() {
    log_section "Copying User Configuration Files"

    if [[ -z "$LAUNCHER_OS_ROOT" ]]; then
        log_error "LAUNCHER_OS_ROOT not set"
        return 1
    fi

    if [[ ! -d "$LAUNCHER_OS_ROOT/config" ]]; then
        log_error "Configuration directory not found: $LAUNCHER_OS_ROOT/config"
        return 1
    fi

    log_progress "Creating user config directory..."
    run_command "mkdir -p ~/.config" "Failed to create ~/.config directory"

    log_progress "Copying configuration files to ~/.config..."
    run_command "cp -R '$LAUNCHER_OS_ROOT/config/'* ~/.config/" "Failed to copy configuration files"

    log_success "User configuration files copied successfully"
    return 0
}
