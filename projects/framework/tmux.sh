#!/bin/bash
# Tmux session for framework (rstats)

SESSION="fw"
PROJECT_DIR="/home/erik/Projects/framework"
SITE_DIR="/home/erik/Projects/framework-site"

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

# --- site (framework-site shell) ---
tmux new-window -t $SESSION:$TABNO -n "site" -c "$SITE_DIR"
TABNO=$((TABNO+1))

# --- site-cl (claude in site dir) ---
tmux new-window -t $SESSION:$TABNO -n "site-cl" -c "$SITE_DIR"
tmux send-keys -t $SESSION:$TABNO "claude" C-m
TABNO=$((TABNO+1))

# --- R ---
tmux new-window -t $SESSION:$TABNO -n "R" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "R" C-m
TABNO=$((TABNO+1))

# --- gui-srv (plumber/dev server on port 8080) ---
tmux new-window -t $SESSION:$TABNO -n "gui-srv" -c "$PROJECT_DIR/gui-dev"
tmux send-keys -t $SESSION:$TABNO "lsof -ti :8080 | xargs kill 2>/dev/null; npm run dev:server" C-m
TABNO=$((TABNO+1))

# --- gui-npm (vite dev server) ---
tmux new-window -t $SESSION:$TABNO -n "gui-npm" -c "$PROJECT_DIR/gui-dev"
tmux send-keys -t $SESSION:$TABNO "npm run dev" C-m
TABNO=$((TABNO+1))

# --- site-npm (site dev server) ---
tmux new-window -t $SESSION:$TABNO -n "site-npm" -c "$SITE_DIR"
tmux send-keys -t $SESSION:$TABNO "npm run dev" C-m
TABNO=$((TABNO+1))

# --- project ---
tmux new-window -t $SESSION:$TABNO -n "project" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# Select first window
tmux select-window -t $SESSION:1

# Attach
tmux attach-session -t $SESSION
