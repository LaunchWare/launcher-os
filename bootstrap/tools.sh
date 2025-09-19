#!/usr/bin/env bash
# Install desktop environment tools

bootstrap_tools() {
    log_section "Installing Desktop Tools"

    local bootstrap_dir="$(dirname "${BASH_SOURCE[0]}")"

    # Install tools from official repos
    install_from_package_list "$bootstrap_dir/packages/tools.txt" \
        "desktop environment tools"

    # Install tools from AUR
    install_aur_from_package_list "$bootstrap_dir/packages/tools-aur.txt" \
        "desktop environment tools from AUR"

    log_success "Desktop tools installation complete"
    return 0
}