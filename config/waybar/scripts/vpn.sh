#!/bin/bash
# Waybar module for JH VPN status (Pulse Secure)

# Check if VPN tunnel is actually established (tun interface exists)
if ip link show tun0 &>/dev/null; then
    # VPN is connected
    echo '{"text": "󰖂", "tooltip": "JH VPN Connected", "class": "connected"}'
else
    # VPN is disconnected - show nothing
    echo '{"text": "", "tooltip": "JH VPN Disconnected", "class": "disconnected"}'
fi
