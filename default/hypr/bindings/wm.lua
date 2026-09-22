-- A complete copy/paste of https://raw.githubusercontent.com/basecamp/omarchy/refs/heads/master/default/hypr/bindings/tiling.conf

-- Close windows
hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close active window" })

-- Control tiling
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" }) -- dwindle
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { description = "Pseudo window" })      -- dwindle
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Force full screen" })
hl.bind("ALT + F11", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })

-- Move focus with SUPER + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }), { description = "Move focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }), { description = "Move focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }), { description = "Move focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }), { description = "Move focus down" })

-- Switch workspaces with SUPER + [0-9]
-- Move active window to a workspace with SUPER + SHIFT + [0-9]
-- Bound by keycode so the binds survive non-QWERTY layouts: code:10 is `1`, code:19 is `0`.
for workspace = 1, 10 do
    local key = "code:" .. (workspace + 9)

    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }),
        { description = "Switch to workspace " .. workspace })
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }),
        { description = "Move window to workspace " .. workspace })
end

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
hl.bind("SUPER + SHIFT + left", hl.dsp.window.swap({ direction = "l" }), { description = "Swap window to the left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window to the right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- Resize active window
hl.bind("SUPER + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
    { description = "Expand window left" }) -- - key
hl.bind("SUPER + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
    { description = "Shrink window left" }) -- = key
hl.bind("SUPER + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }),
    { description = "Shrink window up" })
hl.bind("SUPER + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true }),
    { description = "Expand window down" })

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll active workspace forward" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll active workspace backward" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })
