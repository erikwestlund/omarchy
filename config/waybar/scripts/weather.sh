#!/bin/bash
# Weather script using Pirate Weather API with caching

SECRETS_FILE="$HOME/.config/secrets/config"
WEATHER_CACHE="/tmp/weather_data"
CACHE_AGE=1800  # 30 minutes

# Default coordinates (Milton, MA)
LAT="42.2495"
LON="-71.0662"

# Load API key from secrets
if [[ -f "$SECRETS_FILE" ]]; then
    source "$SECRETS_FILE"
fi

# Check cache first
if [[ -f "$WEATHER_CACHE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$WEATHER_CACHE"))) -lt $CACHE_AGE ]]; then
    cat "$WEATHER_CACHE"
    exit 0
fi

# Fetch from Pirate Weather if we have an API key
if [[ -n "$PIRATE_WEATHER_API_KEY" ]]; then
    response=$(curl -s --max-time 10 "https://api.pirateweather.net/forecast/${PIRATE_WEATHER_API_KEY}/${LAT},${LON}?units=us&exclude=minutely,hourly,daily,alerts" 2>/dev/null)

    if [[ -n "$response" ]]; then
        temp=$(echo "$response" | jq -r '.currently.temperature // empty' 2>/dev/null)
        if [[ -n "$temp" ]]; then
            # Round to integer and format
            temp_rounded=$(printf "%.0f" "$temp")
            output="${temp_rounded}°F "
            echo "$output" > "$WEATHER_CACHE"
            echo "$output"
            exit 0
        fi
    fi
fi

# Fallback to cached data if available
if [[ -f "$WEATHER_CACHE" ]]; then
    cat "$WEATHER_CACHE"
else
    echo "-- "
fi
