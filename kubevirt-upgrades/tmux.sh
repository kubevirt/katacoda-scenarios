#!/bin/bash
SESSION=$USER

tmux -2 new-session -d -s $SESSION

# Setup a window for tailing log files
tmux new-window -t $SESSION:1 -n 'Pods'
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "watch 'kubectl -n kubevirt get pods'" C-m
tmux select-pane -t 1

# Set default window
tmux select-window -t $SESSION:1

# Attach to session
tmux -2 attach-session -t $SESSION