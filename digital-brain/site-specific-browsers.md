# Site-Specific Browser Setup for launcher-os (Wayland/Hyprland)

## Omarchy's Approach

Omarchy uses a simple but effective two-script system:

### 1. `omarchy-webapp-install`
- **Interactive Setup**: Uses `gum` for CLI prompts or accepts command-line args
- **Icon Management**: Downloads icons from URLs or uses local files
- **Desktop Entry**: Creates `.desktop` files in `~/.local/share/applications/`
- **Launcher Integration**: Apps appear in system launcher (SUPER + SPACE)

### 2. `omarchy-launch-webapp`
- **Browser Detection**: Auto-detects default browser via `xdg-settings`
- **Chromium Fallback**: Defaults to Chromium if no compatible browser found
- **App Mode Launch**: Uses `--app="$URL"` flag for standalone windows
- **Process Management**: Uses `uwsm-app` for proper session integration

## Alternative Solutions

### Chrome/Chromium Native (Recommended for launcher-os)
- **Built-in**: Chrome Menu → More Tools → Create Shortcut → "Open as window"
- **Wayland Compatible**: Works with Chromium (already installed in launcher-os)
- **Management**: View all apps at `chrome://apps/`
- **Hyprland Issues**: Minor scaling/fullscreen quirks in Wayland mode

### Nativefier (Electron-based)
- **Heavy**: Each app is a full Electron bundle (~150MB+)
- **Cross-platform**: Works on all platforms
- **Installation**: `npm install -g nativefier`
- **Usage**: `nativefier "https://gmail.com" --name "Gmail"`

### Firefox SSB
- **Native Support**: `about:preferences#pwa` (experimental)
- **Command Line**: `firefox --ssb https://gmail.com`
- **Not Available**: Firefox not included in launcher-os

## Recommendations for launcher-os

### Best Option: Enhanced Omarchy-style Script
Create a simplified version using your existing Chromium installation:

```bash
#!/bin/bash
# webapp-install
NAME="$1"
URL="$2"
ICON_URL="${3:-}"

# Create desktop entry
cat > ~/.local/share/applications/${NAME}.desktop << EOF
[Desktop Entry]
Name=$NAME
Exec=chromium --app="$URL"
Icon=${ICON_URL:-web-browser}
Type=Application
Categories=Network;
EOF
```

### Wayland-Specific Considerations
- **Chromium Flags**: May need `--enable-features=UseOzonePlatform --ozone-platform=wayland`
- **Environment**: launcher-os already forces Wayland (`GDK_BACKEND=wayland`)
- **Scaling Issues**: Minor UI problems in pure Wayland mode, but functional

### Quick Setup Commands
```bash
# Gmail
chromium --app="https://mail.google.com"

# Google Calendar
chromium --app="https://calendar.google.com"

# Zoom Web
chromium --app="https://zoom.us/wc"
```

### Integration with Vicinae Launcher
Since launcher-os uses Vicinae, desktop entries created in `~/.local/share/applications/` will automatically appear in your SUPER + SPACE launcher.

## URL Handler Configuration

To automatically open specific URLs with site-specific browsers (e.g., Zoom links with Zoom SSB):

### 1. Create MIME Type Desktop Entry
```bash
# ~/.local/share/applications/zoom-web.desktop
[Desktop Entry]
Name=Zoom Web App
Exec=chromium --app="https://zoom.us/wc/%u"
Icon=zoom
Type=Application
Categories=Network;
MimeType=x-scheme-handler/zoom;x-scheme-handler/zoommtg;
```

### 2. Register URL Handlers
```bash
# Register zoom:// protocol handler
xdg-mime default zoom-web.desktop x-scheme-handler/zoom
xdg-mime default zoom-web.desktop x-scheme-handler/zoommtg

# For web URLs with specific domains, create a custom handler
xdg-mime default zoom-web.desktop text/html
```

### 3. Advanced URL Routing Script
For more granular control, create a URL router script:

```bash
#!/bin/bash
# ~/.local/bin/url-router
URL="$1"

case "$URL" in
    *zoom.us/j/*|*zoom.us/wc/*)
        chromium --app="https://zoom.us/wc/${URL##*/}" ;;
    *mail.google.com*|*gmail.com*)
        chromium --app="https://mail.google.com" ;;
    *calendar.google.com*)
        chromium --app="https://calendar.google.com" ;;
    *)
        chromium "$URL" ;;
esac
```

Then set it as your default browser:
```bash
xdg-settings set default-web-browser url-router.desktop
```

## Keybind Integration with Launch-or-Focus

launcher-os includes a `launch-os-launch-or-focus.sh` script that either focuses an existing window or launches the app if not found.

### How it Works
```bash
# Usage: launch-os-launch-or-focus.sh [window-pattern] [launch-command]
# - Searches for window matching pattern (class + title)
# - If found: focuses that window
# - If not found: executes launch command
```

### Example Keybind Configuration
Add to your Hyprland bindings (e.g., `~/.config/hypr/bindings.conf` or custom file):

```bash
# Gmail SSB
bind = SUPER, G, exec, launch-os-launch-or-focus.sh "Gmail" "chromium --app=https://mail.google.com"

# Google Calendar SSB
bind = SUPER, C, exec, launch-os-launch-or-focus.sh "Calendar" "chromium --app=https://calendar.google.com"

# Zoom Web SSB
bind = SUPER, Z, exec, launch-os-launch-or-focus.sh "Zoom" "chromium --app=https://zoom.us/wc"

# Alternative: Use more specific window patterns
bind = SUPER, M, exec, launch-os-launch-or-focus.sh "mail.google.com" "chromium --app=https://mail.google.com"
```

### Window Pattern Matching
The script matches against `window.class + " " + window.title`, so you can use patterns like:
- `"Gmail"` - matches any window with "Gmail" in class or title
- `"mail.google.com"` - matches windows with the domain in title
- `"Chromium.*Zoom"` - regex for Chromium windows with Zoom in title

### Testing Window Patterns
To find the right pattern for your SSB windows:
```bash
# List all windows with class and title
hyprctl clients -j | jq -r '.[]|(.class + " " + .title)'

# Test your pattern
hyprctl clients -j | jq -r --arg p "Gmail" '.[]|select((.class+" "+.title)|test($p;"i"))|.address'
```

## Implementation Plan for launcher-os

### Add SSB Infrastructure to launcher-os

1. **Create SSB Installation Script**
   - Add `bin/launcher-os-install-webapp` script (similar to omarchy's approach)
   - Include in bootstrap process or as optional post-install utility
   - Support interactive mode and command-line args

2. **Add Default SSB Configurations**
   - Create `default/applications/` directory structure
   - Include desktop entries for common apps (Gmail, Calendar, Zoom)
   - Template files that get copied during installation

3. **Integrate URL Router into System**
   - Add URL router script to `bin/launcher-os-url-router`
   - Create corresponding desktop entry in `default/applications/`
   - Set up MIME type associations in bootstrap process

4. **Add Hyprland Keybind Defaults**
   - Create `default/hypr/bindings/ssb.conf` for SSB-specific keybinds
   - Include launch-or-focus bindings for common apps
   - Source in main bindings.conf

5. **Update Installation Bootstrap**
   - Modify `install/bootstrap/index.sh` to:
     - Copy SSB desktop entries to user applications
     - Set up URL handlers and MIME associations
     - Configure default browser to URL router
     - Make scripts executable

6. **Documentation Integration**
   - Update main README with SSB setup instructions
   - Add SSB configuration to user customization docs
   - Include troubleshooting section for URL handling

### File Structure Changes Needed

```
launcher-os/
├── bin/
│   ├── launcher-os-install-webapp       # Interactive SSB creator
│   └── launcher-os-url-router          # Smart URL routing
├── default/
│   ├── applications/
│   │   ├── gmail-ssb.desktop
│   │   ├── calendar-ssb.desktop
│   │   ├── zoom-ssb.desktop
│   │   └── url-router.desktop
│   └── hypr/bindings/
│       └── ssb.conf                     # SSB keybinds
└── install/bootstrap/
    └── ssb.sh                          # SSB setup during install
```