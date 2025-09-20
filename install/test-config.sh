#!/usr/bin/env bash
# Test script to run installation pipeline: config only by default, or full pipeline with --full

set -euo pipefail

# Get the directory of this script
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all install modules
source "$INSTALL_DIR/lib/index.sh"
source "$INSTALL_DIR/precheck/index.sh"
source "$INSTALL_DIR/bootstrap/index.sh"
source "$INSTALL_DIR/config/index.sh"

show_usage() {
    echo "Usage: $0 [--full]"
    echo "  --full    Run full installation pipeline (precheck -> bootstrap -> config)"
    echo "  (default) Run configuration phase only"
}

main() {
    local run_full=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full)
                run_full=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [[ "$run_full" == true ]]; then
        log_section "=🚀 Full Launcher OS Installation Pipeline"

        # Run precheck first
        log_info "Starting precheck phase..."
        if ! run_all_prechecks; then
            log_error "Precheck failed - aborting installation"
            exit 1
        fi

        # Run bootstrap installation
        log_info "Starting bootstrap phase..."
        if ! run_bootstrap_installation; then
            log_error "Bootstrap installation failed - aborting"
            exit 1
        fi

        # Run configuration installation
        log_info "Starting configuration phase..."
        if ! run_config_installation; then
            log_error "Configuration installation failed"
            exit 1
        fi

        log_section "✅ Installation Complete!"
        log_success "Launcher OS has been installed successfully!"
    else
        log_section "=⚙️ Launcher OS Configuration"

        # Run configuration installation only
        log_info "Starting configuration phase..."
        if ! run_config_installation; then
            log_error "Configuration installation failed"
            exit 1
        fi

        log_section "✅ Configuration Complete!"
        log_success "Launcher OS configuration has been applied successfully!"
    fi

    log_info "You may need to log out and back in for all changes to take effect."
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi