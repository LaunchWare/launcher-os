hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --watch cliphist store")

    hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("uwsm app -- vicinae server")

    hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
end)
