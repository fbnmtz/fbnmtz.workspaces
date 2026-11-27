-- Fixed workspace shortcuts for the two configured monitors.
-- Loaded by ~/.config/hypr/bindings.lua only while this widget is in shell.json.
--
-- MONITOR NAMES are resolved with this priority (per monitor):
--   1. environment: FBNMTZ_MON_DP / FBNMTZ_MON_HDMI   (user override)
--   2. known connector name if that monitor exists: DP-1 / HDMI-A-2
--   3. auto-detect: connected monitors sorted by name, 1st/2nd slot
--      (uses hl.get_monitors(); NO `hyprctl` IPC, which would block reload)
--   4. built-in fallback DP-1 / HDMI-A-2; if that monitor is absent,
--      the keybind simply does nothing.
-- Find real connector names with `hyprctl monitors`.
-- This file is optional -- the widget works without loading it.
local function monitor_names()
    local names = {}
    local ok, mons = pcall(function()
        if hl and hl.get_monitors then return hl.get_monitors() end
        return {}
    end)
    if ok and type(mons) == "table" then
        for _, m in ipairs(mons) do
            local n = m and m.name
            if n and n ~= "" then names[#names + 1] = n end
        end
    end
    table.sort(names)
    return names
end

local detected = monitor_names()

local function pick_monitor(env_name, preferred, detect_index, hard_default)
    local v = os.getenv(env_name)
    if v and v ~= "" then return v end
    for _, n in ipairs(detected) do
        if n == preferred then return preferred end
    end
    return detected[detect_index] or hard_default
end

local MON_DP = pick_monitor("FBNMTZ_MON_DP", "DP-1", 1, "DP-1")
local MON_HDMI = pick_monitor("FBNMTZ_MON_HDMI", "HDMI-A-2", 2, "HDMI-A-2")

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

-- Custom shortcut moved from ~/.config/hypr/bindings.lua:
-- alternate between current and previous workspace (replaces Omarchy's SUPER + TAB "Next workspace").
o.rebind("SUPER + Tab", "Previous workspace", hl.dsp.focus({ workspace = "prev" }))
