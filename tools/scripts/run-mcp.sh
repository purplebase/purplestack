#!/bin/bash

# Script to ensure dependencies are up to date before running purplestack MCP server
# This ensures the MCP server has all required dependencies available

set -e

# Try fvm flutter pub get first, fallback to flutter pub get if it fails
if command -v fvm >/dev/null 2>&1; then
    fvm flutter pub get || flutter pub get
else
    flutter pub get
fi

# Run the purplestack MCP server
exec dart run purplestack_mcp.dart "$@" 