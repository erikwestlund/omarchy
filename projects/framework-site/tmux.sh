#!/bin/bash
# Tmux session for framework-site (laravel)

SESSION="fwsite"
PROJECT_DIR="/home/erik/Projects/framework-website"

# Check if session already exists
tmux has-session -t $SESSION 2>/dev/null
if [ $? = 0 ]; then
    tmux attach-session -t $SESSION
    exit 0
fi

# Start window numbering at 1
TABNO=1

# --- bash ---
tmux new-session -d -s $SESSION -n "bash" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# --- claude-o (opus) ---
tmux new-window -t $SESSION:$TABNO -n "claude-o" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model opus" C-m
TABNO=$((TABNO+1))

# --- claude-s (sonnet) ---
tmux new-window -t $SESSION:$TABNO -n "claude-s" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model sonnet" C-m
TABNO=$((TABNO+1))

# --- codex (medium reasoning) ---
tmux new-window -t $SESSION:$TABNO -n "codex" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "codex --model gpt-5.1-codex -c model_reasoning_effort=\"medium\"" C-m
TABNO=$((TABNO+1))

# --- codex-gpt (high reasoning) ---
tmux new-window -t $SESSION:$TABNO -n "codex-gpt" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "codex --model gpt-5.1 -c model_reasoning_effort=\"high\"" C-m
TABNO=$((TABNO+1))

# --- docker ---
tmux new-window -t $SESSION:$TABNO -n "docker" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "docker compose up" C-m
TABNO=$((TABNO+1))

# --- npm ---
tmux new-window -t $SESSION:$TABNO -n "npm" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "npm run dev" C-m
TABNO=$((TABNO+1))

# --- artisan ---
tmux new-window -t $SESSION:$TABNO -n "artisan" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# --- tinker ---
tmux new-window -t $SESSION:$TABNO -n "tinker" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "php artisan tinker" C-m
TABNO=$((TABNO+1))

# --- project ---
tmux new-window -t $SESSION:$TABNO -n "project" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# Select first window
tmux select-window -t $SESSION:1

# Attach
tmux attach-session -t $SESSION
