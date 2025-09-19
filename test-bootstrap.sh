#!/usr/bin/env bash
# Test script to run full precheck + bootstrap

set -euo pipefail

# Source the precheck barrel
source precheck/index.sh

# Source the bootstrap barrel
source bootstrap/index.sh

# Run prechecks first
echo "Running preinstall validation..."
if ! run_all_prechecks; then
    echo "Precheck failed - aborting bootstrap"
    exit 1
fi

echo
echo "Prechecks passed! Starting bootstrap installation..."
echo

# Run bootstrap installation
run_bootstrap_installation