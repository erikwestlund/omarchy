#!/bin/bash
# Track window focus changes for toggle-last-window

# Prevent multiple instances
LOCKFILE="/tmp/hypr-focus-tracker.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

STATE_FILE="/tmp/hypr-window-history"

# Find socket - handle dynamic instance signature
for dir in /run/user/1000/hypr/*/; do
    if [[ -S "${dir}.socket2.sock" ]]; then
        SOCKET="${dir}.socket2.sock"
        break
    fi
done

[[ -z "$SOCKET" ]] && exit 1

# Initialize with current window
CURRENT=$(hyprctl activewindow -j | jq -r '.address')

# Listen for activewindow events
while read -r line; do
    if [[ "$line" == activewindowv2\>\>* ]]; then
        ADDR="${line#activewindowv2>>}"
        NEW="0x$ADDR"
        if [[ -n "$ADDR" && "$NEW" != "$CURRENT" ]]; then
            echo "$CURRENT" > "$STATE_FILE"
            CURRENT="$NEW"
        fi
    fi
done < <(socat -u "UNIX-CONNECT:$SOCKET" -)
