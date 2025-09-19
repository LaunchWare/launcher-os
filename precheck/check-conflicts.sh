#!/usr/bin/env bash
# Check for conflicting desktop environments

precheck_conflicts() {
    log_progress "Checking for conflicting desktop environments..."

    local conflicts=()

    # Check for GNOME
    if has_package gnome-shell; then
        conflicts+=("GNOME (gnome-shell)")
    fi

    # Check for KDE/Plasma
    if has_package plasma-desktop; then
        conflicts+=("KDE Plasma (plasma-desktop)")
    fi

    # Check for XFCE
    if has_package xfce4-session; then
        conflicts+=("XFCE (xfce4-session)")
    fi

    # Check for Cinnamon
    if has_package cinnamon-session; then
        conflicts+=("Cinnamon (cinnamon-session)")
    fi

    # Check for MATE
    if has_package mate-session-manager; then
        conflicts+=("MATE (mate-session-manager)")
    fi

    # Check for LXQt
    if has_package lxqt-session; then
        conflicts+=("LXQt (lxqt-session)")
    fi

    if [[ ${#conflicts[@]} -gt 0 ]]; then
        log_warning "Found potentially conflicting desktop environments:"
        for conflict in "${conflicts[@]}"; do
            log_info "  - $conflict"
        done
        echo
        log_warning "These may conflict with Hyprland. Consider removing them before proceeding."
        log_info "You can continue, but you may need to manage conflicts manually."
        return 2  # Warning, not error
    fi

    log_success "No conflicting desktop environments detected"
    return 0
}