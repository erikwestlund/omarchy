#!/usr/bin/env bash

# Combined bluetooth, network, audio, sysinfo status

# Bluetooth
if command -v bluetoothctl &>/dev/null; then
    bt_powered=$(bluetoothctl show 2>/dev/null | grep "Powered: yes")
    bt_connected=$(bluetoothctl devices Connected 2>/dev/null | head -1)
    if [ -n "$bt_connected" ]; then
        bt="󰂱"
    elif [ -n "$bt_powered" ]; then
        bt="󰂯"
    else
        bt="󰂲"
    fi
else
    bt=""
fi

# Network
if ip route | grep -q default; then
    net="󰀂"
else
    net="󰤮"
fi

# Audio
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo 1)
if [ "$muted" = "1" ]; then
    audio="󰖁"
else
    audio="󰕾"
fi

# Sysinfo (CPU icon)
sys="󰍛"

# Single space between icons, no trailing gap
echo "{\"text\": \"$bt $net $audio $sys\", \"class\": \"connectivity\"}"
