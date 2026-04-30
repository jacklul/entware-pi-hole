#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
repository="$1"
[ ! -d "$repository" ] && [ -d "$script_dir/../dev/$repository" ] && repository="$script_dir/../dev/$repository"

if [ -z "$repository" ] || [ ! -d "$repository" ]; then
    echo "Usage: $0 <repository path>"
    exit 1
fi

repository="$(realpath "$repository")"

GIT_TAG=$(git -C "$repository" describe --tags 2> /dev/null || echo "")

# If the tag is not exact, ignore it
if [[ "$GIT_TAG" == *"-"*"-g"* ]]; then
    GIT_TAG=""
fi

#shellcheck disable=SC2015
echo "VERSION=$([ -n "$GIT_TAG" ] && echo "$GIT_TAG" || git -C "$repository" describe --tags --always 2> /dev/null)" > "$repository/.version"

#shellcheck disable=SC2015
echo "BRANCH=$([ -n "$GIT_TAG" ] && echo "master" || git -C "$repository" rev-parse --abbrev-ref HEAD)" >> "$repository/.version"

echo "HASH=$(git -C "$repository" rev-parse --short=8 HEAD)" >> "$repository/.version"

cat "$repository/.version"
