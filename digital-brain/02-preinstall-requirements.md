# Preinstall Requirements & Validation

## System Requirements

### Operating System
- **Arch Linux** (or Arch-based distro)
- Verify via `/etc/os-release` or `pacman --version`

### User Context
- **NOT running as root**
- Must be regular user with sudo privileges
- Verify via `$EUID` check and `sudo -v` test

### Package Manager
- **Pacman must be available**
- Verify pacman is in PATH and functional
- Check for basic pacman operations

### Desktop Environment Conflicts
- **No GNOME installed** (prevents Wayland conflicts)
- **No KDE/Plasma installed** (prevents compositor conflicts)
- Check for gnome-shell, plasma-desktop packages
- Warn if detected, offer removal guidance

## Internal Tooling

### Gum for User Interface
- **charmbracelet/gum** for beautiful shell interactions
- Progress bars, confirmations, selections
- Better UX than basic shell prompts
- Install early in process for script UI

## Validation Script Structure
```bash
#!/usr/bin/env bash
# 00-preinstall-check.sh

1. Check if Arch Linux
2. Verify not running as root
3. Test sudo access
4. Verify pacman availability
5. Scan for conflicting DEs
6. Install gum for UI
7. Present summary and confirm proceed
```

## Error Handling
- Clear error messages with gum styling
- Guidance for fixing each requirement
- Option to continue with warnings (advanced users)
- Graceful exit with next steps