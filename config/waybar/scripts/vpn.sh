#!/bin/bash
# Waybar module for JH VPN status (Pulse Secure)

if pgrep -f "pulsesvc" > /dev/null 2>&1; then
    # VPN is connected
    echo '{"text": "󰖂", "tooltip": "JH VPN Connected", "class": "connected"}'
else
    # VPN is disconnected - show nothing
    echo '{"text": "", "tooltip": "JH VPN Disconnected", "class": "disconnected"}'
fi
