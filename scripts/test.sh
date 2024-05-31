#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PREFIX="$1"
TARGET="$2"

if [ -z "$PREFIX" ] || [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
    echo "Usage: $0 <prefix> <target>"
    exit 1
fi

TARGET="$(realpath "$TARGET")"
PREFIX="${PREFIX,,}" # Force prefix to be lowercase

FILES="$(find "$(readlink -f "$SCRIPT_DIR/../tests")" -type f -name "$PREFIX-*.sh" | sort)"
for FILE in $FILES; do
    echo "Running test: $FILE"
    bash "$FILE" "$TARGET" || exit 1
done

echo "All tests passed"
exit 0
