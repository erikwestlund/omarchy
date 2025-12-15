#!/bin/bash
# Navigate workspaces with mouse buttons, but not in browsers
# Usage: mouse-workspace.sh [next|prev]

# Get active window class
class=$(hyprctl activewindow -j | jq -r '.class // ""')

# Skip in browsers - let them handle back/forward
case "$class" in
    chromium|Chromium|google-chrome|firefox|brave*)
        exit 0
        ;;
esac

# Navigate workspace
if [[ "$1" == "next" ]]; then
    hyprctl dispatch workspace e+1
else
    hyprctl dispatch workspace e-1
fi
