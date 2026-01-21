#!/bin/bash
# Tmux session for clinical-data-visualization (rstats)

SESSION="cdv"
PROJECT_DIR="/home/erik/Projects/clinical-data-visualization"
VENV_ACTIVATE="source .venv/bin/activate"

# Disable VS Code shell integration that causes OSC escape sequence leaks
export TERM_PROGRAM=
export VSCODE_SHELL_INTEGRATION=

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

# --- claude-1 (opus) ---
tmux new-window -t $SESSION:$TABNO -n "claude-1" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model opus" C-m
TABNO=$((TABNO+1))

# --- claude-2 (opus) ---
tmux new-window -t $SESSION:$TABNO -n "claude-2" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model opus" C-m
TABNO=$((TABNO+1))

# --- opencode ---
tmux new-window -t $SESSION:$TABNO -n "opencode" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "opencode" C-m
TABNO=$((TABNO+1))

# --- codex (medium reasoning) ---
tmux new-window -t $SESSION:$TABNO -n "codex" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "codex --model gpt-5.1-codex -c model_reasoning_effort=\"medium\"" C-m
TABNO=$((TABNO+1))

# --- codex-gpt (high reasoning) ---
tmux new-window -t $SESSION:$TABNO -n "codex-gpt" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "codex --model gpt-5.1 -c model_reasoning_effort=\"high\"" C-m
TABNO=$((TABNO+1))

# --- R ---
tmux new-window -t $SESSION:$TABNO -n "R" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "cd $PROJECT_DIR && R" C-m
TABNO=$((TABNO+1))

# --- python ---
tmux new-window -t $SESSION:$TABNO -n "python" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "cd $PROJECT_DIR && [ -d .venv ] && $VENV_ACTIVATE; python3" C-m
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
