#!/bin/bash

#MS_IGNORE

# Root script folder
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if aliases if given as args
if [ $# -lt 1 ]; then
    echo "Usage: ms <alias> [<param1> <param2> ...]"
    exit 1
fi

alias="$1"
shift  # Removing $1 from args

# Check if aliases list file exists
if [ ! -f "$SCRIPT_DIR/aliases.txt" ]; then
    echo "Aliases list doesn't exists. Please check installation"
    exit 1
fi

# Get alias source file path
file_path=$(grep "^$alias=" "$SCRIPT_DIR/aliases.txt" | cut -d '=' -f 2)

# If alias is not found
if [ -z "$file_path" ]; then
    echo "Alias '$alias' not found in aliases list."
    exit 1
fi

# Check if alias source file not found
if [ ! -f "$file_path" ]; then
    echo "File coressponding to '$alias' ($file_path) not found."
    exit 1
fi

# Check if the file need to be executed as sudo
# To do so, we check if the alias source file contains #MS_SUDO
if grep -q "^#MS_SUDO" "$file_path"; then
    sudo bash "$file_path" "$@"
else
    bash "$file_path" "$@"
fi
