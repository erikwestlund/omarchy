#!/bin/bash
# Navigate to next/previous workspace that has windows
# Usage: workspace-with-windows.sh next|prev
# Order: U, 1, 2, 3, ..., 12 (circular). Never includes special workspaces like scratch.

direction=$1
current_ws=$(hyprctl activeworkspace -j | jq -r '.name')

# Build ordered list: numeric workspaces first (sorted), then named workspaces
# Named workspaces have negative IDs in Hyprland
readarray -t numeric_ws < <(hyprctl workspaces -j | jq -r '.[] | select(.id > 0) | .id' | sort -n)
readarray -t named_ws < <(hyprctl workspaces -j | jq -r '.[] | select(.id < 0 and (.name | startswith("special:") | not)) | .name' | sort)

# Combine into ordered list: U first, then numbers
ordered_ws=("${named_ws[@]}" "${numeric_ws[@]}")

# Find current position in ordered list
current_idx=-1
for i in "${!ordered_ws[@]}"; do
    if [ "${ordered_ws[$i]}" = "$current_ws" ]; then
        current_idx=$i
        break
    fi
done

# If current workspace not in list (empty?), go to first
if [ "$current_idx" -eq -1 ]; then
    [ "${#ordered_ws[@]}" -gt 0 ] && hyprctl dispatch workspace "${ordered_ws[0]}"
    exit 0
fi

count=${#ordered_ws[@]}
if [ "$direction" = "next" ]; then
    next_idx=$(( (current_idx + 1) % count ))
else
    next_idx=$(( (current_idx - 1 + count) % count ))
fi

target="${ordered_ws[$next_idx]}"
# Named workspaces need "name:" prefix
if [[ "$target" =~ ^[0-9]+$ ]]; then
    hyprctl dispatch workspace "$target"
else
    hyprctl dispatch workspace "name:$target"
fi
