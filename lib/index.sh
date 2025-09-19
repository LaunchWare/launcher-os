#!/usr/bin/env bash
# Barrel file for lib utilities - exports all common functions

set -euo pipefail

# Get the directory of this script
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all utility modules
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/package-utils.sh"
source "$LIB_DIR/aur-utils.sh"

# Export main directory for other scripts
export LIB_DIR