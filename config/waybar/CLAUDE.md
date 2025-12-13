# Waybar Configuration

Custom Waybar setup with workspace indicators showing window counts.

## Goal

Replicate SketchyBar workspace display:
```
0 U    1 P (2)    2 S (2)    3 F (2)    4 N    5 K    6 L (2)    [9 Computing (3)]    10 C (4)    11 W    12 M (3)
```

- Workspace number + short name
- Window count in parentheses (only if >1)
- Full name when focused (e.g., "Computing" instead of "C")
- Visual distinction: focused / has-windows / empty

## Implementation

### Approach: Custom Module with Hyprland IPC

Waybar's native `hyprland/workspaces` is limited. Use a custom module that:
1. Listens to Hyprland socket for workspace/window events
2. Queries workspace and client state via `hyprctl`
3. Outputs styled workspace indicators

### Files to Create

```
config/waybar/
├── config.jsonc          # Waybar config with custom workspaces module
├── style.css             # Styling for workspace indicators
└── scripts/
    └── workspaces.sh     # IPC listener + formatter
```

### Script: workspaces.sh

```bash
#!/usr/bin/env bash
# Listens to Hyprland IPC and outputs workspace JSON for Waybar

# Workspace names (index = workspace number)
SHORT_NAMES=("U" "P" "S" "F" "N" "K" "L" "S1" "S2" "C" "C" "W" "M")
FULL_NAMES=("Utility" "Pequod" "Shoes" "Framework" "NA-Accord" "ParkUKB" "Flint" "Scratch" "Scratch" "Computing" "Comms" "Work" "Misc")

get_workspaces() {
    # Get active workspace
    active=$(hyprctl activeworkspace -j | jq -r '.id')

    # Get window counts per workspace
    # hyprctl clients -j | jq 'group_by(.workspace.id) | ...'

    # Build output for each workspace 0-12
    # Format: class for styling, text for display
}

# Listen to Hyprland socket for events
socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r event; do
    case $event in
        workspace*|openwindow*|closewindow*|movewindow*)
            get_workspaces
            ;;
    esac
done
```

### Waybar Config (config.jsonc)

```json
{
    "modules-left": ["custom/workspaces"],

    "custom/workspaces": {
        "exec": "~/.config/waybar/scripts/workspaces.sh",
        "return-type": "json",
        "format": "{}",
        "on-click": "hyprctl dispatch workspace {}"
    }
}
```

Alternative: Use multiple `custom/ws-N` modules (one per workspace) for individual click handling and styling.

### Styling (style.css)

```css
#custom-workspaces {
    /* Container */
}

.workspace {
    padding: 0 8px;
    border-radius: 12px;
    margin: 0 2px;
}

.workspace.focused {
    background: rgba(183, 189, 248, 0.53);  /* Blue highlight */
    color: #24273a;
}

.workspace.has-windows {
    background: rgba(73, 77, 100, 0.33);
    color: #cad3f5;
}

.workspace.empty {
    background: rgba(73, 77, 100, 0.27);
    color: #a5adcb;
}
```

## Alternative: Individual Workspace Modules

For better click handling, create 13 separate modules (ws-0 through ws-12):

```json
{
    "modules-left": [
        "custom/ws-0", "custom/ws-1", "custom/ws-2", ...
    ],

    "custom/ws-1": {
        "exec": "~/.config/waybar/scripts/workspace.sh 1",
        "return-type": "json",
        "on-click": "hyprctl dispatch workspace 1"
    }
}
```

Each script instance outputs JSON for its workspace:
```json
{"text": "1 P (2)", "class": "has-windows", "tooltip": "Pequod - 2 windows"}
```

## Hyprland IPC Reference

```bash
# Get active workspace
hyprctl activeworkspace -j

# Get all workspaces (includes window count)
hyprctl workspaces -j

# Get all clients (windows)
hyprctl clients -j

# Listen to events
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock -
# Events: workspace>>, openwindow>>, closewindow>>, movewindow>>
```

## Dependencies

- `jq` - JSON parsing
- `socat` - IPC socket communication

Both should be available on Omarchy by default.
