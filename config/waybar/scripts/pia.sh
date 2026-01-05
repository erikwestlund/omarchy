#!/usr/bin/env bash
# PIA VPN status indicator for Waybar

if ! command -v piactl &>/dev/null; then
    echo '{"text": "", "class": "disconnected"}'
    exit 0
fi

state=$(timeout 1 piactl get connectionstate 2>/dev/null)

if [ "$state" = "Connected" ]; then
    region=$(timeout 1 piactl get region 2>/dev/null || echo "unknown")
    ip=$(timeout 1 piactl get vpnip 2>/dev/null || echo "unknown")
    echo "{\"text\": \"󰖂     \", \"class\": \"connected\", \"tooltip\": \"PIA: $region\\n$ip\"}"
else
    echo '{"text": "", "class": "disconnected"}'
fi
