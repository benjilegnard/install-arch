#!/bin/bash

# This script browse the config directory, and for each file found, copy files from ~/.config (same subdirectory and name) if they exists

# Set base directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG_DIR="$SCRIPT_DIR/config"
HOME_CONFIG_DIR="$HOME/.config"

# List files recursively from ./config/
find "$LOCAL_CONFIG_DIR" -type f | while read -r local_file; do
    # Get the relative path from LOCAL_CONFIG_DIR
    rel_path="${local_file#$LOCAL_CONFIG_DIR/}"

    # Construct the corresponding path in ~/.config/
    source_file="$HOME_CONFIG_DIR/$rel_path"

    # Only copy if the source file exists
    if [[ -f "$source_file" ]]; then
        # Ensure the destination directory exists
        mkdir -p "$(dirname "$local_file")"

        # Copy the file from ~/.config to ./config/
        cp "$source_file" "$local_file"
        echo "🔄Synced: $source_file -> $local_file"
    else
        echo "↩️Skipped (not found): $source_file"
    fi
done

