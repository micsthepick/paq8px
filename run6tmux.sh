#!/bin/bash

# Start a detached tmux session named 'mysession'
tmux new-session -d -s mysession

# Create 5 additional panes for a total of 6, adjusting layout to tiled
for i in {1..5}; do
    tmux split-window -h -t mysession
    tmux select-layout tiled > /dev/null 2>&1 # Adjust layout to tiled after each split
done

# Normalize layout again to ensure it's as tiled as possible
tmux select-layout tiled

# Assign M variable and run the script in each pane
for i in {1..6}; do
    letter=$(echo {a..f} | cut -d ' ' -f $i)
    tmux send-keys -t $(($i - 1)) "M=$letter ./runarg.sh" C-m
done

# Attach to the tmux session
tmux attach -t mysession