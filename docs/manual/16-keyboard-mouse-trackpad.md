# Keyboard, Mouse, Trackpad

## Configuration File

Settings are managed in `~/.config/hypr/input.conf`

Access through the Omarchy menu via `Super + Alt + Space` under Setup > Input.

## Keyboard Settings

### Multiple Keyboard Layouts

Switch layouts with `Alt + Space`:
```
kb_layout = us,dk
```

### Keyboard Repeat

```
repeat_rate = 40
repeat_delay = 600
```

### Compose Key and Layout Toggle

Configure via `kb_options`

### Key Remapping

Swap Alt and Super keys:
```
kb_options = compose:caps,altwin:swap_alt_win
```

## Mouse & Trackpad

### Sensitivity

```
sensitivity = 0.35
```
Default is 0.

### Natural Scrolling

```
natural_scroll = true
```

### Two-finger Right-click

```
clickfinger_behavior = true
```

### Scroll Speed

```
scroll_factor = 0.3
```

## Special Configuration

Window rule for faster scrolling in terminals:
```
windowrule = scrolltouchpad 1.5, tag:terminal
```

## Reference

See the Hyprland wiki for inputs for comprehensive options documentation.
