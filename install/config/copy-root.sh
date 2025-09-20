#!/usr/bin/env bash
# Copy launcher-os project files to system location

export LAUNCHER_OS_ROOT=/usr/local/share/launcher-os

config_copy_root() {
    log_section "Copying Project Root to System"

    # Get the project root directory (two levels up from this script)
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/../.." && pwd)"

    log_progress "Removing existing installation at $LAUNCHER_OS_ROOT..."
    run_command "sudo rm -rf '$LAUNCHER_OS_ROOT'" "Failed to remove existing installation"

    log_progress "Creating target directory: $LAUNCHER_OS_ROOT"
    run_command "sudo mkdir -p '$LAUNCHER_OS_ROOT'" "Failed to create target directory"

    log_progress "Copying project files (excluding git files)..."
    run_command "sudo rsync -av --exclude='.git*' --exclude='digital-brain' '$project_root/' '$LAUNCHER_OS_ROOT/'" "Failed to copy project files"

    log_success "Project files copied successfully to $LAUNCHER_OS_ROOT"
    return 0
}

