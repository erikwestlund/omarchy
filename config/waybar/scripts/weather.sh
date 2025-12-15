#!/bin/bash
# Weather script - auto-detect location via ipinfo.io, fallback to Milton, MA

CACHE_FILE="/tmp/weather_location"
CACHE_AGE=3600  # 1 hour

# Check if cached location exists and is fresh
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_AGE ]]; then
    location=$(cat "$CACHE_FILE")
else
    # Get location from ipinfo.io
    location=$(curl -s --max-time 3 ipinfo.io 2>/dev/null | jq -r '"\(.city),\(.region)"' 2>/dev/null)

    # Fallback if detection fails
    if [[ -z "$location" || "$location" == "null,null" || "$location" == "," ]]; then
        location="Milton,MA"
    fi

    echo "$location" > "$CACHE_FILE"
fi

# Get weather for location
echo "$(curl -s --max-time 5 "wttr.in/${location}?format=%t&u" 2>/dev/null | sed 's/+//')  "
