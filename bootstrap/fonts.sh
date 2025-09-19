#!/usr/bin/env bash
# Install fonts for development

bootstrap_fonts() {
    log_section "Installing Fonts"

    local bootstrap_dir="$(dirname "${BASH_SOURCE[0]}")"

    install_from_package_list "$bootstrap_dir/packages/fonts.txt" \
        "development fonts"

    # Refresh font cache
    log_progress "Refreshing font cache..."
    fc-cache -fv >/dev/null 2>&1

    log_success "Fonts installation complete"
    return 0
}