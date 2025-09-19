# Modular Script Architecture - Node.js Barrel Pattern

## Directory Structure
```
precheck/
├── index.sh               # Barrel - exports all precheck functions
├── check-arch.sh          # Verify Arch Linux
├── check-user.sh          # Verify not root + sudo access
├── check-pacman.sh        # Verify pacman functionality
├── check-conflicts.sh     # Check for conflicting DEs
└── install-gum.sh         # Install gum for UI

bootstrap/
├── index.sh               # Barrel - orchestrates all installations
├── hyprland.sh            # Core Hyprland installation
├── fonts.sh               # Fira Code Nerd Font
├── apps.sh                # Alacritty, Chromium, Vivaldi
├── tools.sh               # Walker, Mako, Waybar
├── configs.sh             # Base configurations
└── theme.sh               # Catppuccin theming

lib/
├── index.sh               # Barrel - exports common utilities
├── colors.sh              # Color definitions and styling
├── logging.sh             # Logging and output functions
└── utils.sh               # Common utility functions
```

## Barrel Pattern Benefits
- **Familiar**: Follows Node.js conventions
- **Clean imports**: `source precheck/index.sh` gets everything
- **Encapsulation**: Internal structure hidden from consumers
- **Flexible**: Easy to reorganize without breaking imports
- **Discoverable**: Clear entry points for each module

## Usage Pattern
```bash
# Main installer
source lib/index.sh       # Get utilities
source precheck/index.sh  # Get all precheck functions
source bootstrap/index.sh # Get installation functions

# Run prechecks
run_all_prechecks

# Run installation
run_bootstrap_installation
```

## Script Standards
- Each module exports functions via its index.sh
- Use `set -euo pipefail` for safety
- Consistent naming: `module_function_name`
- Exit codes: 0=success, 1=error, 2=warning