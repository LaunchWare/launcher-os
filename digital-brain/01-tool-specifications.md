# Tool Specifications for Base Setup

## Core Applications

### Terminal
- **Alacritty**: GPU-accelerated, excellent font rendering
- Configuration: Minimal setup with Fira Code Nerd Font
- Theme: Catppuccin integration

### Browsers
- **Chromium**: Primary development browser (DevTools, extensions)
- **Vivaldi**: Daily browsing (privacy, customization, workspaces)

### Fonts
- **Fira Code Nerd Font**: Primary monospace with ligatures
- Includes all nerd font symbols for terminal/statusbar compatibility

### Display/Window Management
- **Hyprland**: Wayland compositor
- **Waybar**: Status bar (or equivalent)
- **Walker**: Application launcher (modern, extensible, Wayland-native)
- **Mako**: Notification daemon (lightweight, auto-starting)

## Application Launcher - Walker
- Modern Wayland-native runner used by Omarchy
- Built-in modules: applications, runner, hyprland windows, websearch
- Can run as service for faster startup times
- Extensible architecture
- Keyboard-driven workflow integration

## Notification Daemon - Mako
- Lightweight notification daemon for Wayland
- Auto-starts on first notification (no manual service setup)
- Simple configuration in `~/.config/mako/config`
- Works seamlessly with Hyprland
- Chosen by Omarchy for its simplicity and reliability

## Development Foundation
- Essential CLI tools for development workflow
- Package managers (system-level)
- Basic utilities that work well with zsh/tmux/asdf stack

## Theme Consistency
- **Catppuccin**: Unified color scheme across all applications
- Variants: Mocha (dark) as default, with macchiato option
- GTK/Qt theme compatibility

## Integration Points
- Alacritty config ready for dotfiles override
- Browser profile directories accessible
- Font installation system-wide
- Theme files in standard locations
- Walker and Mako configs prepared for customization