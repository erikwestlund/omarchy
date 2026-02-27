#!/bin/bash
# Tmux session for career (utility)

SESSION="career"
PROJECT_DIR="$HOME/Projects/career"

# Check if session already exists
tmux has-session -t $SESSION 2>/dev/null
if [ $? = 0 ]; then
    # Only attach if running interactively (in a terminal)
    if [ -t 1 ]; then
        tmux attach-session -t $SESSION
    else
        echo "ok"
    fi
    exit 0
fi

# Start window numbering at 1
TABNO=1

# --- bash ---
tmux new-session -d -s $SESSION -n "bash" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# --- opencode-1 ---
tmux new-window -t $SESSION:$TABNO -n "opencode-1" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "tmux-opencode"
TABNO=$((TABNO+1))

# --- opencode-2 ---
tmux new-window -t $SESSION:$TABNO -n "opencode-2" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "tmux-opencode"
TABNO=$((TABNO+1))

# --- claude-1 ---
tmux new-window -t $SESSION:$TABNO -n "claude-1" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "tmux-claude"
TABNO=$((TABNO+1))

# --- claude-2 ---
tmux new-window -t $SESSION:$TABNO -n "claude-2" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "tmux-claude"
TABNO=$((TABNO+1))

# --- project ---
tmux new-window -t $SESSION:$TABNO -n "project" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# Select first window
tmux select-window -t $SESSION:1

# Attach only if running interactively
if [ -t 1 ]; then
    tmux attach-session -t $SESSION
else
    echo "ok"
fi
