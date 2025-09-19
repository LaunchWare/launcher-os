#!/usr/bin/env bash
# Install core applications

bootstrap_apps() {
    log_section "Installing Applications"

    local bootstrap_dir="$(dirname "${BASH_SOURCE[0]}")"

    install_from_package_list "$bootstrap_dir/packages/apps.txt" \
        "core applications"

    log_success "Applications installation complete"
    return 0
}