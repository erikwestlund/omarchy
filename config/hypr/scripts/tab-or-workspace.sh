#!/bin/bash
# Switch tabs in Chromium, or move workspace otherwise
# Usage: tab-or-workspace.sh prev|next

direction="$1"
window_class=$(hyprctl activewindow -j | jq -r '.class // ""')

if [[ "$window_class" == "chromium" ]]; then
    # Small delay to let user release Super+Shift
    sleep 0.1
    if [[ "$direction" == "prev" ]]; then
        wtype -M ctrl -M shift -k Tab -m shift -m ctrl
    else
        wtype -M ctrl -k Tab -m ctrl
    fi
else
    if [[ "$direction" == "prev" ]]; then
        hyprctl dispatch movetoworkspace r-1
    else
        hyprctl dispatch movetoworkspace r+1
    fi
fi
