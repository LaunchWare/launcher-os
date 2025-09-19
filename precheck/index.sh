#!/usr/bin/env bash
# Barrel file for precheck functions - orchestrates all validation

set -euo pipefail

# Get the directory of this script
PRECHECK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities (assume lib is sibling to precheck)
source "$(dirname "$PRECHECK_DIR")/lib/index.sh"

# Source all precheck modules
source "$PRECHECK_DIR/check-arch.sh"
source "$PRECHECK_DIR/check-user.sh"
source "$PRECHECK_DIR/check-pacman.sh"
source "$PRECHECK_DIR/check-conflicts.sh"
source "$PRECHECK_DIR/check-gum.sh"

# Main precheck orchestrator function
run_all_prechecks() {
    log_section "🚀 Hyprland Base Setup - Preinstall Validation"

    local has_errors=false
    local has_warnings=false

    # Run all critical checks (errors will fail installation)
    if ! precheck_arch; then
        has_errors=true
    fi

    if ! precheck_user; then
        has_errors=true
    fi

    if ! precheck_pacman; then
        has_errors=true
    fi

    if ! precheck_gum; then
        has_errors=true
    fi

    # Check for conflicts (warnings only)
    if ! precheck_conflicts; then
        case $? in
            2) has_warnings=true ;;
            *) has_errors=true ;;
        esac
    fi

    # Handle results
    if [[ "$has_errors" == true ]]; then
        log_error "Preinstall validation failed with errors"
        log_info "Please resolve the above issues and try again"
        return 1
    fi

    if [[ "$has_warnings" == true ]]; then
        log_warning "Preinstall validation completed with warnings"
        if ! confirm "Continue despite warnings?"; then
            log_info "Installation cancelled"
            return 1
        fi
    else
        log_success "All preinstall validations passed!"
        if ! confirm "Proceed with Hyprland installation?"; then
            log_info "Installation cancelled"
            return 1
        fi
    fi

    log_success "Ready to proceed with installation!"
    return 0
}

# Export main directory for other scripts
export PRECHECK_DIR