#!/bin/bash

# Run watch command as a background task
watch -n 1 afl-whatsup /outs/out &

# Start a detached tmux session named 'mysession'
tmux new-session -d -s mysession

# Create 11 additional panes for a total of 12, adjusting layout to tiled
for i in {1..11}; do
    tmux split-window -h -t mysession
    tmux select-layout tiled > /dev/null 2>&1 # Adjust layout to tiled after each split
done

# Normalize layout again to ensure it's as tiled as possible
tmux select-layout tiled

# Assign M variable and run the script in each pane
for i in {1..12}; do
    letter=$(echo {a..l} | cut -d ' ' -f $i)
    tmux send-keys -t $(($i - 1)) "M=$letter ./runarg.sh" C-m
done

# Attach to the tmux session
tmux attach -t mysession