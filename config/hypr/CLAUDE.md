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

F-key navigation is implemented:

| Binding | Action |
|---------|--------|
| F1-F12 | Switch to workspace 1-12 |
| Alt + F1-F12 | Move window to workspace 1-12 |
| Super + grave | Toggle special workspace |
| Alt + h/j/k/l | Move focus (vim-style) |
| Alt + Shift + h/j/k/l | Swap windows |

Note: Alt+F9 is broken by Framework EC firmware - use Super+Shift+9 to move windows to workspace 9.

## Laptop Suspend/Resume Fix

The laptop has a custom `hypridle.conf` deployed via Ansible to fix black screen/broken lock screen issues after suspend resume.

**Problem**: After resuming from suspend, the display stack may not be ready when hyprlock/hyprland tries to interact with it, causing crashes or black screens.

**Solution**: Add a delay after resume before turning on DPMS:
```
after_sleep_cmd = sleep 1 && hyprctl dispatch dpms on
```

**Configuration**: Set in `ansible/host_vars/laptop.yml`:
```yaml
hypridle_after_sleep_delay: 1  # seconds to wait after resume
```

**To revert**:
1. Remove or set to 0: `hypridle_after_sleep_delay: 0` in `host_vars/laptop.yml`
2. Re-run ansible: `ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags dotfiles`
3. Or simply delete `~/.config/hypr/hypridle.conf` to fall back to Omarchy defaults

**References**:
- https://github.com/basecamp/omarchy/issues/3293
- https://github.com/basecamp/omarchy/issues/1147

## Reference

- Hyprland wiki: https://wiki.hyprland.org/
- Commands: `hyprctl dispatch workspace 1`, `hyprctl dispatch movetoworkspace 1`
