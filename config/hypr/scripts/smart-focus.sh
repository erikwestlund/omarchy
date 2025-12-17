#!/bin/bash
# Smart focus: move focus between windows, or switch workspace at edges
# Usage: smart-focus.sh left|right

direction=$1
workspace_id=$(hyprctl activeworkspace -j | jq '.id')
active_addr=$(hyprctl activewindow -j | jq -r '.address')

# Get sorted list of active (non-empty) workspace IDs
active_workspaces=($(hyprctl workspaces -j | jq -r '.[].id' | sort -n))

# Find next/previous active workspace
switch_workspace() {
    local dir=$1
    local current=$workspace_id
    local target=""

    if [ "$dir" = "right" ]; then
        # Find first workspace with ID > current
        for ws in "${active_workspaces[@]}"; do
            if [ "$ws" -gt "$current" ]; then
                target=$ws
                break
            fi
        done
        # Wrap to first if none found
        [ -z "$target" ] && target=${active_workspaces[0]}
    else
        # Find last workspace with ID < current
        for ws in "${active_workspaces[@]}"; do
            if [ "$ws" -lt "$current" ]; then
                target=$ws
            fi
        done
        # Wrap to last if none found
        [ -z "$target" ] && target=${active_workspaces[-1]}
    fi

    [ -n "$target" ] && hyprctl dispatch workspace "$target"
}

# Get all windows in current workspace
windows_json=$(hyprctl clients -j | jq '[.[] | select(.workspace.id == '"$workspace_id"' and .mapped == true)]')
window_count=$(echo "$windows_json" | jq 'length')

if [ "$window_count" -le 1 ]; then
    # Single window (or none): switch workspace
    switch_workspace "$direction"
else
    # Get x position of active window and find min/max x positions
    active_x=$(echo "$windows_json" | jq '.[] | select(.address == "'"$active_addr"'") | .at[0]')
    min_x=$(echo "$windows_json" | jq '[.[].at[0]] | min')
    max_x=$(echo "$windows_json" | jq '[.[].at[0]] | max')

    if [ "$direction" = "left" ] && [ "$active_x" = "$min_x" ]; then
        # Leftmost window, going left: previous workspace
        switch_workspace left
    elif [ "$direction" = "right" ] && [ "$active_x" = "$max_x" ]; then
        # Rightmost window, going right: next workspace
        switch_workspace right
    else
        # Normal focus movement
        if [ "$direction" = "right" ]; then
            hyprctl dispatch movefocus r
        else
            hyprctl dispatch movefocus l
        fi
    fi
fi
