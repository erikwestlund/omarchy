#!/usr/bin/env bash
# ============================================================================
# Waybar Workspace Indicator
# ============================================================================
# Usage: workspace.sh <workspace_id>
# Outputs JSON for Waybar custom module with workspace name and window count
#
# Listens to Hyprland IPC for real-time updates
# ============================================================================

WORKSPACE="$1"

# Workspace names
declare -A SHORT_NAMES FULL_NAMES
SHORT_NAMES[U]="U"    FULL_NAMES[U]="Utility"
SHORT_NAMES[1]="P"    FULL_NAMES[1]="Pequod"
SHORT_NAMES[2]="S"    FULL_NAMES[2]="Shoes"
SHORT_NAMES[3]="F"    FULL_NAMES[3]="Framework"
SHORT_NAMES[4]="N"    FULL_NAMES[4]="NA-Accord"
SHORT_NAMES[5]="K"    FULL_NAMES[5]="ParkUKB"
SHORT_NAMES[6]="L"    FULL_NAMES[6]="Flint"
SHORT_NAMES[7]="S1"   FULL_NAMES[7]="Scratch"
SHORT_NAMES[8]="S2"   FULL_NAMES[8]="Scratch"
SHORT_NAMES[9]="C"    FULL_NAMES[9]="Computing"
SHORT_NAMES[10]="C"   FULL_NAMES[10]="Comms"
SHORT_NAMES[11]="W"   FULL_NAMES[11]="Work"
SHORT_NAMES[12]="M"   FULL_NAMES[12]="Misc"

SHORT_NAME="${SHORT_NAMES[$WORKSPACE]}"
FULL_NAME="${FULL_NAMES[$WORKSPACE]}"

output_workspace() {
    # Get active workspace
    if [[ "$WORKSPACE" == "U" ]]; then
        ACTIVE=$(hyprctl activeworkspace -j | jq -r 'if .name == "U" then "true" else "false" end')
        WINDOW_COUNT=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "U")] | length')
    else
        ACTIVE=$(hyprctl activeworkspace -j | jq -r --argjson ws "$WORKSPACE" 'if .id == $ws then "true" else "false" end')
        WINDOW_COUNT=$(hyprctl clients -j | jq --argjson ws "$WORKSPACE" '[.[] | select(.workspace.id == $ws)] | length')
    fi

    # Build display text - just number + window count
    # OLD VERSION WITH LETTERS (commented for reference):
    # FAINT="alpha='70%'"
    # if [[ "$WORKSPACE" == "U" ]]; then
    #     NAME_LABEL="<span weight='medium'>$SHORT_NAME</span>"
    # else
    #     if [[ "$ACTIVE" == "true" ]]; then
    #         NAME_LABEL="<span weight='medium'>$WORKSPACE</span> <span weight='light'>$FULL_NAME</span>"
    #     else
    #         NAME_LABEL="<span weight='medium'>$WORKSPACE</span> <span weight='light' $FAINT>$SHORT_NAME</span>"
    #     fi
    # fi

    # Just number, no labels
    if [[ "$WORKSPACE" == "U" ]]; then
        NAME_LABEL="U"
    else
        NAME_LABEL="$WORKSPACE"
    fi

    # Add window count if any windows exist
    if [[ "$WINDOW_COUNT" -gt 0 ]]; then
        TEXT="$NAME_LABEL <span weight='light'>($WINDOW_COUNT)</span>"
    else
        TEXT="$NAME_LABEL"
    fi

    # Determine CSS class
    if [[ "$ACTIVE" == "true" ]]; then
        CLASS="focused"
    elif [[ "$WINDOW_COUNT" -gt 0 ]]; then
        CLASS="has-windows"
    else
        CLASS="empty"
    fi

    # Get window titles for tooltip
    if [[ "$WORKSPACE" == "U" ]]; then
        WINDOW_LIST=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "U") | .title' | head -10)
    else
        WINDOW_LIST=$(hyprctl clients -j | jq -r --argjson ws "$WORKSPACE" '.[] | select(.workspace.id == $ws) | .title' | head -10)
    fi

    # Build tooltip with window list
    if [[ -n "$WINDOW_LIST" ]]; then
        # Convert newlines to \n for JSON, add bullets
        WINDOW_LIST_ESCAPED=$(echo "$WINDOW_LIST" | sed 's/^/• /' | tr '\n' '\a' | sed 's/\a/\\n/g' | sed 's/\\n$//')
        TOOLTIP="$FULL_NAME ($WINDOW_COUNT)\\n$WINDOW_LIST_ESCAPED"
    else
        TOOLTIP="$FULL_NAME (empty)"
    fi

    # Escape quotes for JSON
    TOOLTIP=$(echo "$TOOLTIP" | sed 's/"/\\"/g')

    # Output JSON for Waybar
    echo "{\"text\": \"$TEXT\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
}

# Initial output
output_workspace

# Listen to Hyprland socket for events
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
if [[ -S "$SOCKET" ]]; then
    socat -u "UNIX-CONNECT:$SOCKET" - 2>/dev/null | while read -r event; do
        case "$event" in
            workspace*|openwindow*|closewindow*|movewindow*|focusedmon*|activewindow*)
                output_workspace
                ;;
        esac
    done
fi
