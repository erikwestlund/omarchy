#!/bin/bash
# Darkman mode indicator for waybar

mode=$(darkman get 2>/dev/null || echo "unknown")

case "$mode" in
    light)
        echo '{"text": "󰖨    ", "tooltip": "Light mode - click to toggle", "class": "light"}'
        ;;
    dark)
        echo '{"text": "󰖙    ", "tooltip": "Dark mode - click to toggle", "class": "dark"}'
        ;;
    *)
        echo '{"text": "?    ", "tooltip": "Unknown mode"}'
        ;;
esac
