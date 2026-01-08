#!/bin/bash
# Tmux session for framework (rstats)

SESSION="fw"
PROJECT_DIR="/home/erik/Projects/framework"
SITE_DIR="/home/erik/Projects/framework-site"

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
tmux send-keys -t $SESSION:$TABNO "opencode" C-m
TABNO=$((TABNO+1))

# --- opencode-2 ---
tmux new-window -t $SESSION:$TABNO -n "opencode-2" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "opencode" C-m
TABNO=$((TABNO+1))

# --- claude (opus) ---
tmux new-window -t $SESSION:$TABNO -n "claude" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model opus" C-m
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
tmux send-keys -t $SESSION:$TABNO "cd $PROJECT_DIR && R" C-m
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

# Attach only if running interactively
if [ -t 1 ]; then
    tmux attach-session -t $SESSION
else
    echo "ok"
fi
