-- Fixed workspace shortcuts for the two configured monitors.
-- Loaded by ~/.config/hypr/bindings.lua only while this widget is in shell.json.
--
-- MACHINE-SPECIFIC: set your monitor connector names (see `hyprctl monitors`).
-- Overridable from the environment; if a named monitor is absent, its
-- keybinds simply do nothing. This file is optional -- the widget works
-- without loading it.
local MON_DP = os.getenv("FBNMTZ_MON_DP") or "DP-1"
local MON_HDMI = os.getenv("FBNMTZ_MON_HDMI") or "HDMI-A-2"

-- Super + 1-0 and F1-F10 select HDMI-A-2; Alt selects DP-1.
for slot = 1, 20 do
    local key
    if slot <= 10 then
        key = "code:" .. tostring(slot + 9)
    else
        key = "F" .. tostring(slot - 10)
    end

    -- The plugin owns both the fixed-monitor navigation and move shortcuts.
    o.rebind("SUPER + " .. key, "HDMI-A-2 - Workspace " .. slot,
        o.workspaces.focus(slot, MON_HDMI))
    o.rebind("ALT + " .. key, "DP-1 - Workspace " .. slot,
        o.workspaces.focus(slot, MON_DP))
    o.rebind("SUPER + SHIFT + " .. key, "Mover janela para HDMI-A-2 - Workspace " .. slot,
        o.workspaces.move_window(slot, true, MON_HDMI))
    o.rebind("ALT + SHIFT + " .. key, "Mover janela para DP-1 - Workspace " .. slot,
        o.workspaces.move_window(slot, true, MON_DP))

    -- Keep Omarchy's silent-move shortcut monitor-fixed for slots 1-10.
    if slot <= 10 then
        o.rebind("SUPER + SHIFT + ALT + " .. key,
            "Mover janela silenciosamente para HDMI-A-2 - Workspace " .. slot,
            o.workspaces.move_window(slot, false, MON_HDMI))
    end
end
