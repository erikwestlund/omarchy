#!/bin/bash
# Navigate to next/previous workspace that has windows
# Usage: workspace-with-windows.sh next|prev

direction=$1
current_ws=$(hyprctl activeworkspace -j | jq '.id')

# Get sorted list of workspace IDs that have windows (active workspaces)
active_workspaces=($(hyprctl workspaces -j | jq -r '.[].id' | sort -n))

if [ "$direction" = "next" ]; then
    # Find first workspace with ID > current
    for ws in "${active_workspaces[@]}"; do
        if [ "$ws" -gt "$current_ws" ]; then
            hyprctl dispatch workspace "$ws"
            exit 0
        fi
    done
    # Wrap to first if none found
    [ "${#active_workspaces[@]}" -gt 0 ] && hyprctl dispatch workspace "${active_workspaces[0]}"
else
    # Find last workspace with ID < current
    target=""
    for ws in "${active_workspaces[@]}"; do
        if [ "$ws" -lt "$current_ws" ]; then
            target=$ws
        fi
    done
    if [ -n "$target" ]; then
        hyprctl dispatch workspace "$target"
    else
        # Wrap to last if none found
        [ "${#active_workspaces[@]}" -gt 0 ] && hyprctl dispatch workspace "${active_workspaces[-1]}"
    fi
fi
