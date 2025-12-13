# FAQ

## How do I switch between keyboard layouts?

Edit `~/.config/hypr/input.conf` and add keyboard layout settings:

```
kb_layout = us,fr
kb_options = compose:caps,grp:alts_toggle
```

Toggle layouts using Left Alt + Right Alt.

## How do I change the clock format to 12-hour?

Modify `~/.config/waybar/config.jsonc` by replacing the clock format string with:

```
"{:%A %I:%M %p}"
```

This displays time like "Sunday 10:55 AM."

## How do I change where screenshots or screenrecordings are saved?

Access Setup > Defaults through the Omarchy menu and set environment variables:

```
OMARCHY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
OMARCHY_SCREENRECORD_DIR="$HOME/Videos/Recordings"
```

Create the directory first and restart Omarchy.

## How do I get the speakers + webcam working on my Apple Studio Display?

Use a WJESOG DisplayPort + USB-A to USB-C cable for reliable functionality.

Built-in brightness controls:
- `Ctrl+F1` - decrease brightness
- `Ctrl+F2` - increase brightness
- `Ctrl+Shift+F2` - maximum brightness

## How do I get rid of all the extra software?

Run Remove > Package from the menu to view and uninstall packages, or use Remove > Web App to eliminate preinstalled web applications.
