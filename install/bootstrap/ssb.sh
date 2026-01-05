#!/usr/bin/env bash

# Bootstrap script to install default site-specific browsers

# Function to install site-specific browsers
bootstrap_ssb() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local launcher_os_dir="$(dirname "$(dirname "$script_dir")")"
    local install_script="$launcher_os_dir/bin/launcher-os-install-webapp"

    log_info "Setting up default site-specific browsers..."

    # Install GMail SSB with official favicon and mailto handler
    "$install_script" "GMail" "https://mail.google.com" "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico" "x-scheme-handler/mailto"

    # Install Google Calendar SSB with official favicon and calendar handlers
    "$install_script" "Google Calendar" "https://calendar.google.com" "https://calendar.google.com/googlecalendar/images/favicon_v2014_2.ico" "text/calendar;application/ics;x-scheme-handler/webcal"

    # Install Zoom Web SSB with official favicon and protocol handlers
    "$install_script" "Zoom" "https://zoom.us/wc" "https://st1.zoom.us/zoom.ico" "x-scheme-handler/zoom;x-scheme-handler/zoommtg"

    log_success "Default site-specific browsers installed"
    log_info "Available SSBs: GMail, Google Calendar, Zoom Web"
    log_info "These will appear in your Vicinae launcher (SUPER + Space)"
    log_info "To add keybinds, see the SSB documentation in digital-brain/"

    return 0
}