# Troubleshooting

## System broken by update?

First try to rollback your system to the version before your recent update.

Use `omarchy-debug` for Discord support or `omarchy-reinstall` to restore defaults.

## Apps appearing oversized?

Omarchy defaults to 2x display scaling via `GDK_SCALE=2`.

Adjust to 1 for standard displays in `~/.config/hypr/hyprland.conf`.

For Spotify specifically: use `Ctrl + Minus` to shrink UI.

## Caps Lock not functioning?

It's designated as the xcompose key for emojis and autocompletions.

Remap in `~/.config/hypr/input.conf`:
```
kb_options = compose:ralt
```

## External speakers silent?

Check waybar speaker icon to set primary audio output as default.

## Password login/sudo issues?

After repeated failed attempts, run from TTY (`Ctrl+Alt+F2`):
```bash
faillock --reset --user [username]
```

## 1Password authorization prompts missing?

1. Enable Settings > Advanced > Use Hardware Acceleration (requires reboot)
2. Ensure 1Password has been launched since boot
