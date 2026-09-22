-- Audio controls (function keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), { locked = true })

-- Brightness controls (function keys)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd('dms ipc call brightness increment 5 ""'), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd('dms ipc call brightness decrement 5 ""'), { locked = true })

-- Precise 1% multimedia adjustments with Alt modifier
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 1"),
    { repeating = true, locked = true, description = "Volume up precise" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 1"),
    { repeating = true, locked = true, description = "Volume down precise" })
hl.bind("ALT + XF86MonBrightnessUp", hl.dsp.exec_cmd('dms ipc call brightness increment 1 ""'),
    { repeating = true, locked = true, description = "Brightness up precise" })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd('dms ipc call brightness decrement 1 ""'),
    { repeating = true, locked = true, description = "Brightness down precise" })

-- Media player controls
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"), { locked = true, description = "Pause" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play"), { locked = true, description = "Play" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })

hl.bind("SUPER + ALT + right", hl.dsp.exec_cmd("playerctl next"), { description = "Next track" })
hl.bind("SUPER + ALT + up", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play" })
hl.bind("SUPER + ALT + left", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous track" })
