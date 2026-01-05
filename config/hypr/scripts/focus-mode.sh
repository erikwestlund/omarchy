#!/bin/bash
# Toggle focus mode - centered floating window with constrained size

WINDOW_INFO=$(hyprctl activewindow -j)
IS_FLOATING=$(echo "$WINDOW_INFO" | jq -r '.floating')

if [[ "$IS_FLOATING" == "true" ]]; then
    # Exit focus mode - tile the window again
    hyprctl dispatch togglefloating
else
    # Enter focus mode
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 1500 90%
    hyprctl dispatch centerwindow
fi
