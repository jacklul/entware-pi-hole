#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

REPOSITORY="$1"

if [ -z "$REPOSITORY" ] || [ ! -d "$REPOSITORY" ]; then
    echo "Usage: $0 <repository path>"
    exit 1
fi

REPOSITORY="$(realpath "$REPOSITORY")"

if [[ "$GITHUB_REF" == refs/tags/* ]] || [[ "$GITHUB_REF" == "refs/heads/master" ]]; then
    GIT_TAG=$(git -C "$REPOSITORY" describe --tags --abbrev=0 2> /dev/null || echo "")
fi

#shellcheck disable=SC2015
echo "VERSION=$([ -n "$GIT_TAG" ] && echo "$GIT_TAG" || git -C "$REPOSITORY" describe --tags --always 2>/dev/null)" > "$REPOSITORY/.version"

#shellcheck disable=SC2015
echo "BRANCH=$([ -n "$GIT_TAG" ] && echo "master" || git -C "$REPOSITORY" rev-parse --abbrev-ref HEAD)" >> "$REPOSITORY/.version"

echo "HASH=$(git -C "$REPOSITORY" rev-parse --short=8 HEAD)" >> "$REPOSITORY/.version"

cat "$REPOSITORY/.version"
