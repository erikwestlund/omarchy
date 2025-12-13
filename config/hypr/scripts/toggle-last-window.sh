#!/bin/bash
# Toggle to last focused window (across workspaces)
# Reads from state file maintained by focus-tracker

STATE_FILE="/tmp/hypr-window-history"

if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

CURRENT=$(hyprctl activewindow -j | jq -r '.address')
LAST=$(head -1 "$STATE_FILE")

if [[ -n "$LAST" && "$LAST" != "$CURRENT" && "$LAST" != "null" ]]; then
    hyprctl dispatch focuswindow "address:$LAST"
fi
