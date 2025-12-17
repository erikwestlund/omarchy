#!/usr/bin/env bash

# Check for active meeting first
if pgrep -x "teams" >/dev/null || pgrep -f "teams-for-linux" >/dev/null; then
    echo '{"text": " Teams Meeting", "class": "teams"}'
    exit 0
fi

if pgrep -x "zoom" >/dev/null; then
    echo '{"text": " Zoom Meeting", "class": "zoom"}'
    exit 0
fi

# Find the first player that is actually playing
player=""
for p in $(playerctl -l 2>/dev/null); do
    if [ "$(playerctl -p "$p" status 2>/dev/null)" = "Playing" ]; then
        player="$p"
        break
    fi
done

if [ -z "$player" ]; then
    echo '{"text": "", "class": "empty"}'
    exit 0
fi

artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)

# Determine icon and class based on player
case "$player" in
    *firefox*|*chromium*|*chrome*|*brave*)
        # Check window titles for YouTube
        if hyprctl clients -j | jq -r '.[].title' | grep -qi "youtube"; then
            icon="▶"
        else
            icon="♪"
        fi
        ;;
    *)
        icon="♪"
        ;;
esac
class="default"

if [ -n "$artist" ] && [ "$artist" != "" ]; then
    display="$artist - $title"
else
    display="$title"
fi

# Truncate on laptop only (desktop has more space)
if [ "$(cat ~/.machine 2>/dev/null)" != "desktop" ] && [ ${#display} -gt 32 ]; then
    display="${display:0:32}..."
fi

text="$icon $display"

echo "{\"text\": \"$text\", \"class\": \"$class\"}"
