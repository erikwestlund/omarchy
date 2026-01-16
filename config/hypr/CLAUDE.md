# Hyprland Configuration

User customizations for Hyprland. Files here sync to `~/.config/hypr/`.

## Omarchy Defaults

Omarchy sources configs in layers:
1. System defaults from `~/.local/share/omarchy/default/hypr/`
2. User overrides from `~/.config/hypr/`

User configs override defaults - don't edit system files directly.

## Files

| File | Purpose |
|------|---------|
| `bindings.conf` | Custom keybindings (app launchers, workspace nav) |
| `input.conf` | Keyboard/mouse/trackpad settings |
| `monitors.conf` | Display scaling and multi-monitor layout |
| `looknfeel.conf` | Gaps, borders, rounding |
| `workspaces.conf` | Workspace names and monitor assignments |
| `autostart.conf` | Apps to launch on login |
| `scripts/` | Helper scripts (focus-tracker, smart-focus, etc.) |

## Workspace Bindings

| Binding | Action |
|---------|--------|
| Super + 1-0 | Switch to workspace 1-10 |
| Super + minus/equal | Switch to workspace 11-12 |
| Super + Shift + 1-0 | Move window to workspace 1-10 |
| Super + grave | Toggle utility workspace |
| Super + h/j/k/l | Move focus (vim-style) |
| Super + Shift + h/j/k/l | Swap windows |

## Reference

- Hyprland wiki: https://wiki.hyprland.org/
- Commands: `hyprctl dispatch workspace 1`, `hyprctl dispatch movetoworkspace 1`
