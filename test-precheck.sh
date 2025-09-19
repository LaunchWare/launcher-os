#!/usr/bin/env bash
# Test script to run precheck validation

set -euo pipefail

# Source the precheck barrel
source precheck/index.sh

# Run all prechecks
run_all_prechecks