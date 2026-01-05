#!/bin/bash
# Waybar module for JH VPN status (Pulse Secure)

# Check if Pulse Secure VPN is connected by looking for pulsesvc with active tunnel
# tun0 alone isn't enough since PIA also uses it
if pgrep -x pulsesvc &>/dev/null && ip link show tun0 &>/dev/null; then
    # Check if PIA is also connected - if so, tun0 belongs to PIA
    pia_state=$(timeout 1 piactl get connectionstate 2>/dev/null)
    if [ "$pia_state" = "Connected" ]; then
        # tun0 is PIA, not JH VPN
        echo '{"text": "", "tooltip": "JH VPN Disconnected", "class": "disconnected"}'
    else
        # JH VPN is connected
        echo '{"text": "󰖂     ", "tooltip": "JH VPN Connected", "class": "connected"}'
    fi
else
    # VPN is disconnected - show nothing
    echo '{"text": "", "tooltip": "JH VPN Disconnected", "class": "disconnected"}'
fi
