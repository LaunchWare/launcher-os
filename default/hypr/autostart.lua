hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- hypridle runs as hypridle.service instead (systemctl --user enable hypridle).
    -- Launched here via uwsm its stdout reaches neither the journal nor
    -- hyprland.log, so idle/sleep events are invisible -- including the
    -- after_sleep_cmd that re-modesets displays on resume. The unit also gives
    -- Restart=on-failure and graphical-session.target lifecycle.
    -- hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("uwsm app -- vicinae server")

    hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
    hl.exec_cmd("systemctl --user enable --now hypridle.service")
end)
