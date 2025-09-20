#!/usr/bin/env bash
# Barrel file for config functions - orchestrates configuration installation

set -euo pipefail

# Get the directory of this script
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities (assume lib is sibling to config)
source "$(dirname "$CONFIG_DIR")/lib/index.sh"

# Source all config modules
source "$CONFIG_DIR/copy-root.sh"
source "$CONFIG_DIR/copy-config.sh"

# Main config orchestrator function
run_config_installation() {
    log_section "🔧 Configuration Installation"

    # Copy project files to system location
    if ! config_copy_root; then
        log_error "Failed to copy project root to system"
        return 1
    fi

    # Copy user configuration files
    if ! config_copy_user_config; then
        log_error "Failed to copy user configuration files"
        return 1
    fi

    log_section "✅ Configuration Installation Complete"
    log_success "All configuration files have been installed successfully!"

    return 0
}

# Export main directory for other scripts
export CONFIG_DIR