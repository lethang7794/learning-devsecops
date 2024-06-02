#!/bin/bash

set -e          # Stop the script on errors
set -u          # Stop the script on unset variables
set -o pipefail # Make the pipe fail if any command fails

files=$(ls)
for file in $files; do
  if [ -f "$file" ]; then
    echo "$file is a regular file"
  else
    echo "$file is not a regular file"
  fi
done
