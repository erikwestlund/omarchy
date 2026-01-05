#!/usr/bin/env bash
# Tmux session indicator for Waybar

sessions=$(tmux list-sessions -F "#{session_name}:#{session_windows}w:#{?session_attached,attached,detached}" 2>/dev/null)

if [ -z "$sessions" ]; then
    echo '{"text": "", "class": "none"}'
    exit 0
fi

count=$(echo "$sessions" | wc -l)
attached=$(echo "$sessions" | grep -c ":attached$")

# Build tooltip with session details
tooltip=""
while IFS= read -r line; do
    name=$(echo "$line" | cut -d: -f1)
    windows=$(echo "$line" | cut -d: -f2)
    status=$(echo "$line" | cut -d: -f3)
    if [ "$status" = "attached" ]; then
        tooltip+="$name ($windows) *\n"
    else
        tooltip+="$name ($windows)\n"
    fi
done <<< "$sessions"
# Remove trailing newline
tooltip=${tooltip%\\n}

echo "{\"text\": \" 󰞷  $count       \", \"tooltip\": \"$tooltip\"}"
