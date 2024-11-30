#!/bin/bash

sourcePath=$1 # requires an argument with full path to fuzzing dir

if [[ -z "$sourcePath" ]]; then
  echo "must provide path to mount point for fuzzing dir"
  exit 1
fi

mkdir -p $sourcePath/out
mkdir -p $sourcePath/seeds-paq8px

#gpt vesion using screen
# Check if the screen session exists
if screen -list | grep -q "fuzzing"; then
  echo "The screen session 'fuzzing' already exists. Attaching to it..."
  screen -rd fuzzing
else
  echo "Creating a new screen session 'fuzzing' and starting an interactive Docker container."
  # Create a new detached screen session that runs the Docker command
  screen -dmS fuzzing
  # Send the Docker command to the screen session for execution
  screen -S fuzzing -X stuff "docker run --rm -ti --name fuzzpaq --mount type=bind,source=$sourcePath,destination=/outs --mount type=tmpfs,destination=/mnt/ramdisk -e AFL_TMPDIR=/mnt/ramdisk fuzzpaq:latest bash run6tmux.sh /outs\n"
  echo "Screen session 'fuzzing' with Docker container started. You can attach to it with 'screen -r fuzzing'."
fi
