#!/usr/bin/env bash
# Test script to run precheck validation

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the precheck barrel
source "$SCRIPT_DIR/precheck/index.sh"

# Run all prechecks
run_all_prechecks