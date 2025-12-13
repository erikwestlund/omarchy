# Hyprland Configuration

User customizations for Hyprland. Files here sync to `~/.config/hypr/`.

## Omarchy Defaults

Omarchy sources configs in layers:
1. System defaults from `~/.local/share/omarchy/default/hypr/`
2. User overrides from `~/.config/hypr/`

User configs override defaults - don't edit system files directly.

## Files

- `bindings.conf` - Custom keybindings (app launchers, workspace nav)
- `input.conf` - Keyboard/mouse/trackpad settings
- `monitors.conf` - Display scaling and multi-monitor layout
- `looknfeel.conf` - Gaps, borders, rounding
- `autostart.conf` - Apps to launch on login

## Workspace Plan

Goal: Replicate AeroSpace-style workflow with F-key navigation and project workspaces.

### Bindings to Add

```
# Navigate workspaces with F1-F12
Super + F1-F12 → workspace 1-12

# Throw window to workspace (and follow)
Alt + F1-F12 → movetoworkspace 1-12

# Launch workspace project
Ctrl + F1-F12 → exec ~/bin/ws 1-12

# Utility workspace (secondary monitor)
Super + grave → special workspace or workspace 0

# Focus navigation (vim-style)
Alt + h/j/k/l → movefocus l/d/u/r

# Swap windows
Alt + Shift + h/j/k/l → swapwindow l/d/u/r
```

### Multi-Monitor Setup

```
# In monitors.conf or workspaces.conf
workspace = 0, monitor:eDP-1    # Utility on laptop/secondary
workspace = 1-12, monitor:DP-1  # Projects on main monitor
```

### Workspace Launcher Script

Create `~/bin/ws` that:
1. Switches to workspace N
2. Reads project config from `~/.config/ws/ws.env.zsh`
3. Launches editor (nvim, vscode, etc.)
4. Opens browser to dev URL
5. Starts/attaches tmux session

### Files to Create

1. `bindings.conf` - F-key workspace bindings + vim navigation
2. `workspaces.conf` - Monitor assignments
3. `~/bin/ws` - Workspace launcher (Hyprland version)
4. `~/.config/ws/ws.env.zsh` - Project definitions (template)

## Reference

- Hyprland wiki: https://wiki.hyprland.org/
- Key codes: `code:10` = 1, `code:11` = 2, etc. (F1 = `code:67`, F12 = `code:78`)
- Commands: `hyprctl dispatch workspace 1`, `hyprctl dispatch movetoworkspace 1`
