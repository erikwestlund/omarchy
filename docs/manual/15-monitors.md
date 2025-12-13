# Monitors

## Display Requirements

Omarchy assumes a 2x-capable retina-class display with 218+ PPI by default, optimized for devices like the Framework 13 (2.8K) and professional monitors such as 27" 5K displays or 32" 6K models.

## Configuration File

All monitor settings are managed in `~/.config/hypr/monitors.conf`

## Scaling Settings

### For 27" or 32" 4K displays (fractional scaling)

```
env = GDK_SCALE,1.75
monitor=,preferred,auto,1.666667
```

### For 1080p or 1440p displays (1x scaling)

```
env = GDK_SCALE,1
monitor=,preferred,auto,1
```

## Important Notes

- Changes to `GDK_SCALE` apply only to applications launched after modification
- Close existing oversized windows after updating settings (use `Ctrl + Alt + Del` to close all)
- Linux on low-resolution displays with fractional scaling has given the platform a bad reputation for fussy fonts

## Multiple Monitor Setup

Hyprland supports multiple displays. Reference the [Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Monitors/) for layout configuration and binding specific workspaces to monitors.

[Hyprmon](https://github.com/erans/hyprmon/) provides a TUI for positioning multiple screens.
