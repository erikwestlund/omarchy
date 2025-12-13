#!/bin/bash
# Show calendar agenda in a popup
# Bind to a key in hyprland: bind = , XF86Calculator, exec, ~/.config/hypr/scripts/agenda.sh

# Sync calendar first (background, don't block)
vdirsyncer sync &>/dev/null &

# Show agenda in notification
agenda=$(khal list today 3d 2>/dev/null)

if [ -z "$agenda" ]; then
    notify-send "Calendar" "No upcoming events" -t 5000
else
    notify-send "Agenda" "$agenda" -t 10000
fi
