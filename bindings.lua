-- Fixed workspace shortcuts, per monitor.
--
-- OPTION D (minimal, no autoload): load ONCE, while the widget is enabled, from
-- ~/.config/hypr/bindings.lua (it does nothing otherwise):
--   dofile((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
--          .. "/omarchy/plugins/fbnmtz.workspaces/bindings.lua")
-- `hyprctl reload` then re-applies. (An optional automatic `toggles/hypr`
-- autoload is NOT used; to be evaluated separately.)
--
-- SELF-GATE: applies nothing unless the fbnmtz.workspaces widget is enabled.
local function widget_active()
    local home = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
    local f = io.open(home .. "/omarchy/shell.json", "r")
    if not f then return false end
    local text = f:read("*a")
    f:close()
    return text:match('"id"%s*:%s*"fbnmtz%.workspaces"') ~= nil
end

if not widget_active() then return end
--
-- MONITOR NAMES are resolved with this priority (per monitor):
--   1. environment: FWS_M01 / FWS_M02 / FWS_M03   (user override)
--   2. auto-detect: connected monitors sorted by name, 1st/2nd/3rd slot
--      (uses hl.get_monitors(); NO `hyprctl` IPC, which would block reload)
-- Monitor 1 is always available and its keys work with just one monitor.
-- Monitor 2 and monitor 3 are OPTIONAL: only used if present/detected.
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

-- Monitor 1: always present (env FWS_M01, else 1st connected monitor). Keys
-- work with just one monitor.
local WS_MONITOR1 = pick_monitor("FWS_M01", nil, 1, nil)
-- Monitor 2 and monitor 3: OPTIONAL, same logic. Only registered when present/
-- detected (or forced with FWS_M02 / FWS_M03). Nothing bound when absent.
local WS_MONITOR2 = pick_monitor("FWS_M02", nil, 2, nil)
local WS_MONITOR3 = pick_monitor("FWS_M03", nil, 3, nil)

-- Monitor 1 always; monitor 2 (SUPER) and monitor 3 (CTRL) only if present.
-- (keys for monitor 1 + monitor 2 differ today; monitor 2 == monitor 3 logic.)
for slot = 1, 20 do
    local key
    if slot <= 10 then
        key = "code:" .. tostring(slot + 9)
    else
        key = "F" .. tostring(slot - 10)
    end

    -- Monitor 1: always registered. (ALT today; works with just one monitor.)
    o.rebind("ALT + " .. key, WS_MONITOR1 .. " - Workspace " .. slot,
        o.workspaces.focus(slot, WS_MONITOR1))
    o.rebind("ALT + SHIFT + " .. key, "Mover janela para " .. WS_MONITOR1 .. " - Workspace " .. slot,
        o.workspaces.move_window(slot, true, WS_MONITOR1))

    -- Monitor 2: same logic as monitor 3, only if present/detected. (SUPER today.)
    if WS_MONITOR2 and WS_MONITOR2 ~= "" then
        o.rebind("SUPER + " .. key, WS_MONITOR2 .. " - Workspace " .. slot,
            o.workspaces.focus(slot, WS_MONITOR2))
        o.rebind("SUPER + SHIFT + " .. key, "Mover janela para " .. WS_MONITOR2 .. " - Workspace " .. slot,
            o.workspaces.move_window(slot, true, WS_MONITOR2))
        -- Keep Omarchy's silent-move shortcut monitor-fixed for slots 1-10.
        if slot <= 10 then
            o.rebind("SUPER + SHIFT + ALT + " .. key,
                "Mover janela silenciosamente para " .. WS_MONITOR2 .. " - Workspace " .. slot,
                o.workspaces.move_window(slot, false, WS_MONITOR2))
        end
    end

    -- Third monitor, same logic, CTRL; only when a third monitor is known.
    if WS_MONITOR3 and WS_MONITOR3 ~= "" then
        o.rebind("CTRL + " .. key, WS_MONITOR3 .. " - Workspace " .. slot,
            o.workspaces.focus(slot, WS_MONITOR3))
        o.rebind("CTRL + SHIFT + " .. key, "Mover janela para " .. WS_MONITOR3 .. " - Workspace " .. slot,
            o.workspaces.move_window(slot, true, WS_MONITOR3))
        if slot <= 10 then
            o.rebind("CTRL + SHIFT + ALT + " .. key,
                "Mover janela silenciosamente para " .. WS_MONITOR3 .. " - Workspace " .. slot,
                o.workspaces.move_window(slot, false, WS_MONITOR3))
        end
    end
end

-- Custom shortcut moved from ~/.config/hypr/bindings.lua:
-- alternate between current and previous workspace (replaces Omarchy's SUPER + TAB "Next workspace").
o.rebind("SUPER + Tab", "Previous workspace", hl.dsp.focus({ workspace = "prev" }))
