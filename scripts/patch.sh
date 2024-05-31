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

FILES="$(find "$(readlink -f "$SCRIPT_DIR/../patches")" -type f \( -name "$PREFIX-*.patch" -or -name "$PREFIX-*.diff" \) | sort)"
for FILE in $FILES; do
    echo "Applying patch file: $FILE"
    git -C "$TARGET" apply -v "$FILE" || exit 1
done

FILES="$(find "$(readlink -f "$SCRIPT_DIR/../patches")" -type f -name "$PREFIX-*.sh" | sort)"
for FILE in $FILES; do
    echo "Running patch script: $FILE"
    bash "$FILE" "$TARGET" || exit 1
done

echo "All patches applied"
exit 0
