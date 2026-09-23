-- Cursor theme and size. Bibata ships no hyprcursor build, so Hyprland uses the
-- XCursor theme; with no theme set it falls back to its bare built-in arrow.
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
