#!/usr/bin/env bash
# Tailscale status indicator for Waybar

status=$(tailscale status --json 2>/dev/null)

if [ -z "$status" ]; then
    echo '{"text": "", "class": "disconnected"}'
    exit 0
fi

backend_state=$(echo "$status" | jq -r '.BackendState')

if [ "$backend_state" = "Running" ]; then
    hostname=$(echo "$status" | jq -r '.Self.HostName')
    ip=$(echo "$status" | jq -r '.TailscaleIPs[0]')
    echo "{\"text\": \" 󰖂     \", \"class\": \"connected\", \"tooltip\": \"Tailscale: $hostname\\n$ip\"}"
else
    echo '{"text": "", "class": "disconnected"}'
fi
