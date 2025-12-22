#!/bin/bash
# Toggle clamshell mode - disable/enable laptop screen
# SAFETY: Only disables eDP-1 if an external DP monitor is active

LAPTOP="eDP-1"
LAPTOP_MODE="2880x1920@120,0x0,2"

# Get monitor info from hyprctl
monitors=$(hyprctl monitors -j)

# Check if external DP monitor exists and is active (not disabled)
external_active=$(echo "$monitors" | jq -r '.[] | select(.name | startswith("DP-")) | select(.disabled == false) | .name' | head -1)

# Check if laptop screen is currently disabled
laptop_disabled=$(echo "$monitors" | jq -r '.[] | select(.name == "eDP-1") | .disabled')

if [ "$laptop_disabled" = "true" ]; then
    # Laptop is disabled, re-enable it
    hyprctl keyword monitor "$LAPTOP,$LAPTOP_MODE"
    notify-send "Clamshell" "Laptop screen enabled"
elif [ -n "$external_active" ]; then
    # External monitor is active, safe to disable laptop
    hyprctl keyword monitor "$LAPTOP,disable"
    notify-send "Clamshell" "Laptop screen disabled (using $external_active)"
else
    # No external monitor - refuse to disable
    notify-send "Clamshell" "No external monitor detected - refusing to disable laptop screen" --urgency=critical
fi
