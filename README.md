# fbnmtz.workspaces

Omarchy shell bar-widget plugin: workspace indicators for Hyprland, per
monitor, with 20 slots per monitor and occupied-workspace filtering.

A personal clone of Omarchy's `omarchy.workspaces`, renamed to
`fbnmtz.workspaces`, plus machine-specific extras. Stock behavior retained:
each monitor shows its own workspace block (1–10, 11–20, …; Omarchy
`monitor-workspaces`), active workspace shows layout glyph (dwindle 󱓻 /
scrolling 󰝥 / floating 󰔶), click cycles layout, wheel scrolls workspaces,
unoccupied hidden workspaces dimmed, "guest" workspaces shown last.

- **Plugin id:** `fbnmtz.workspaces`
- **Kind:** `bar-widget`
- **Entry point:** `Workspaces.qml`
- **Cloned from:** `omarchy.workspaces` (`omarchy.clonedFrom`; calls made to
  `omarchy.workspaces` are routed to this clone while enabled)
- **Author:** fbnmtz

## Changes vs stock `omarchy.workspaces`

- `slots`: **20** (stock 10); slots numbered 1–20, no `0` remap.
- Only **occupied** workspaces (plus the active one, plus monitor "guests")
  are shown; empty hidden workspaces are omitted (stock always shows 1–5).
- Own id `fbnmtz.workspaces`, own `moduleName`, own `ShellIpc` target.
- Ships **`bindings.lua`**: optional Hyprland keybinds for the fixed two-monitor
  layout (below). Not loaded automatically.

## Requirements

- **Omarchy** (Quickshell-based `omarchy-shell`), tested on Omarchy **4.5.0**,
  on **Hyprland**. QML modules `qs.Ui`, `qs.Commons`, `Quickshell.Hyprland`
  come from Omarchy; no network, no extra packages, no root.
- `hyprctl` on `PATH`.
- Omarchy shipped commands: `omarchy-hyprland-workspace-layout-current`,
  `omarchy-hyprland-workspace-layout-toggle`, `omarchy-shell`.
- Reads `${XDG_STATE_HOME:-~/.local/state}/omarchy/monitor-workspaces`
  (written by Omarchy's `monitor-workspaces.lua`; watched live; optional —
  falls back to per-monitor blocks) and, via Omarchy, workspace-layout state
  in `${XDG_STATE_HOME}/omarchy/workspace-layouts/`.
- `bindings.lua` (optional) additionally needs Omarchy's Hyprland Lua API
  (`o.workspaces.focus`, `o.workspaces.move_window`, `o.rebind`, `hl.dsp`).
- **Multi-monitor `bindings.lua` is MACHINE-SPECIFIC.** Defaults `DP-1` /
  `HDMI-A-2`; check `hyprctl monitors`. The core widget does not need it.

Self-contained inside the plugin folder: `manifest.json`, `Workspaces.qml`,
`bindings.lua`. (Any `*.bak` scratch file has been removed.)

## Install

```sh
omarchy plugin add https://github.com/fbnmtz/fbnmtz.workspaces.git --enable
```

Or manually:

```sh
git clone https://github.com/fbnmtz/fbnmtz.workspaces.git \
  ~/.config/omarchy/plugins/fbnmtz.workspaces
omarchy-shell shell rescanPlugins
omarchy plugin enable fbnmtz.workspaces --section left   # keeps existing slot
```

```sh
omarchy plugin validate ~/.config/omarchy/plugins/fbnmtz.workspaces
```

Enabled state lives in `~/.config/omarchy/shell.json`
(a `bar.layout.left` entry `{ "id": "fbnmtz.workspaces" }`; optional extra
`"format"`). While `omarchy.clonedFrom` names `omarchy.workspaces`, the stock
widget is replaced by this clone. Layout cycling's
`omarchy-shell omarchy.workspaces refresh` is routed to this clone; direct
`omarchy-shell fbnmtz.workspaces refresh` also works (`ShellIpc` target
`fbnmtz.workspaces`, `refresh()`).

## Optional keybinds (`bindings.lua`)

Not loaded by Omarchy automatically. Only load it while the widget is enabled,
in `~/.config/hypr/bindings.lua`:

```lua
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local shell_config = io.open(config_home .. "/omarchy/shell.json", "r")
local fbnmtz_workspaces_active = false
if shell_config then
    local config_text = shell_config:read("*a")
    shell_config:close()
    fbnmtz_workspaces_active = config_text:match('"id"%s*:%s*"fbnmtz%.workspaces"') ~= nil
end
if fbnmtz_workspaces_active then
    dofile(config_home .. "/omarchy/plugins/fbnmtz.workspaces/bindings.lua")
end
```

`bindings.lua` itself, for slots 1–20 on two monitors:

- `SUPER + 1..0` then `SUPER + F1..F10` → focus workspace N on **HDMI-A-2**
- `ALT + 1..0` then `ALT + F1..F10` → focus workspace N on **DP-1**
- `SUPER + SHIFT + …` → move window to that workspace on that monitor
- `ALT + SHIFT + …` → move window to that workspace on the other monitor
- `SUPER + SHIFT + ALT + 1..0` → silent move on HDMI-A-2 (slots 1–10)

Monitor names: `local MON_DP` / `local MON_HDMI` at the top of `bindings.lua`,
or env `FBNMTZ_MON_DP` / `FBNMTZ_MON_HDMI`. Keybind description strings are
in Portuguese; edit freely. Then `hyprctl reload && hyprctl configerrors`.
**The `dofile` path must match the renamed plugin directory.**

## Remove

```sh
omarchy plugin remove fbnmtz.workspaces
```

Restores stock `omarchy.workspaces`. Also remove your `dofile(...)` wrapper
from `~/.config/hypr/bindings.lua`, `"id": "fbnmtz.workspaces"` from
`shell.json`, then `hyprctl reload` and `omarchy-shell shell rescanPlugins`.
If you were using `bindings.lua`, revert any `o.rebind` keys it overrode.

## Origin & license

Derived from Omarchy's `omarchy.workspaces` (Omarchy is MIT licensed,
© David Heinemeier Hansson). See `LICENSE`. Omarchy's notice is preserved.
