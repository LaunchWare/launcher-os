# Shell Transition Strategy

## Phase Structure

### Bootstrap Phase (Bash)
- All installation scripts remain in bash
- Install Hyprland base system
- User remains on bash shell throughout
- No shell switching during bootstrap

### Postinstall Phase (Shell Designation)
- **Explicit postinstall module** for shell management
- Install zsh package
- Change user default shell from bash to zsh
- Shell transition handled as separate phase

## Implementation
- Bootstrap completes with working Hyprland + bash
- Postinstall module handles shell switching
- Clean separation between system setup and shell designation
- User gets functional system, then chooses shell environment

## Benefits
- Bootstrap stays focused on Hyprland installation
- Shell switching isolated to dedicated phase
- No mid-installation shell transitions
- Clear handoff between system and user environment setup