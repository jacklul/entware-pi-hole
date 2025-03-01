#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

repository="$1"

if [ -z "$repository" ] || [ ! -d "$repository" ]; then
    echo "Usage: $0 <repository path>"
    exit 1
fi

repository="$(realpath "$repository")"

if [[ "$GITHUB_REF" == refs/tags/* ]] || [[ "$GITHUB_REF" == "refs/heads/master" ]]; then
    GIT_TAG=$(git -C "$repository" describe --tags --abbrev=0 2> /dev/null || echo "")
fi

#shellcheck disable=SC2015
echo "VERSION=$([ -n "$GIT_TAG" ] && echo "$GIT_TAG" || git -C "$repository" describe --tags --always 2>/dev/null)" > "$repository/.version"

#shellcheck disable=SC2015
echo "BRANCH=$([ -n "$GIT_TAG" ] && echo "master" || git -C "$repository" rev-parse --abbrev-ref HEAD)" >> "$repository/.version"

echo "HASH=$(git -C "$repository" rev-parse --short=8 HEAD)" >> "$repository/.version"

cat "$repository/.version"
