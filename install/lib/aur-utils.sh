#!/usr/bin/env bash
# AUR package utilities

# Legacy compatibility - redirect to the main install_aur_packages function in aur.sh
install_aur_from_package_list() {
    install_aur_packages "$@"
}