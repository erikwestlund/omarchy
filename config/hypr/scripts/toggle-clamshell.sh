#!/bin/bash
# Toggle clamshell mode - disable/enable laptop screen
# SAFETY: Only disables eDP-1 if an external DP monitor is active

LAPTOP="eDP-1"
EXTERNAL_DESC="GKT Kuycon G32P"

# Get monitor info from hyprctl
monitors=$(hyprctl monitors -j)

# Check if external monitor exists and is active (not disabled)
external_active=$(echo "$monitors" | jq -r --arg desc "$EXTERNAL_DESC" '.[] | select(.description == $desc) | select(.disabled == false) | .name' | head -1)

# Check if laptop is currently active (enabled and in the list)
laptop_active=$(echo "$monitors" | jq -r '.[] | select(.name == "eDP-1") | select(.disabled == false) | .name')

if [ -z "$laptop_active" ]; then
    # Laptop is disabled, re-enable it (move external first to avoid overlap)
    # Move external to 1440,0 first (it's probably at 0,0 in clamshell mode)
    hyprctl keyword monitor "desc:$EXTERNAL_DESC,6144x3456@60,1440x0,2"
    sleep 0.2
    # Now enable laptop at 0,0
    hyprctl keyword monitor "$LAPTOP,2880x1920@120,0x0,2"
    notify-send "Clamshell" "Laptop screen enabled (Laptop on Left)"
elif [ -n "$external_active" ]; then
    # Laptop is active and external monitor is active, safe to disable laptop
    # Move utility workspace to external before disabling
    hyprctl dispatch moveworkspacetomonitor "name:U $external_active" 2>/dev/null
    hyprctl keyword monitor "$LAPTOP,disable"
    notify-send "Clamshell" "Laptop screen disabled (using $external_active)"
else
    # Laptop is active but no external monitor - refuse to disable
    notify-send "Clamshell" "No external monitor detected - refusing to disable laptop screen" --urgency=critical
fi
