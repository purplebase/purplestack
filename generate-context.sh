#!/bin/bash

# Script to build CONTEXT.md from various markdown files
# All paths are relative to the root of this project

# Remove existing CONTEXT.md if it exists
rm -f CONTEXT.md

# Function to add a file without headers
add_file() {
    local file_path="$1"
    
    if [ -f "$file_path" ]; then
        cat "$file_path" >> CONTEXT.md
        echo "" >> CONTEXT.md
        echo "Adding $file_path to CONTEXT.md"
    else
        echo "Warning: $file_path not found, skipping..."
    fi
}

# Add all .md files from context directory in A-Z0-9 order
for md_file in $(ls context/*.md 2>/dev/null | sort); do
    if [ -f "$md_file" ]; then
        add_file "$md_file"
    fi
done

add_file "../models/README.md"
add_file "CHANGELOG.md"

echo "CONTEXT.md has been successfully created!"