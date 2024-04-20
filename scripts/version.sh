#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

REPOSITORY="$1"

if [ -z "$REPOSITORY" ] || [ ! -d "$REPOSITORY" ]; then
    echo "Usage: $0 <repository>"
    exit 1
fi

REPOSITORY="$(realpath "$REPOSITORY")"

echo "VERSION=$(git -C "$REPOSITORY" describe --tags --always 2>/dev/null)" > "$REPOSITORY/.version"
echo "BRANCH=$(git -C "$REPOSITORY" rev-parse --abbrev-ref HEAD)" >> "$REPOSITORY/.version"
echo "HASH=$(git -C "$REPOSITORY" rev-parse --short=8 HEAD)" >> "$REPOSITORY/.version"
