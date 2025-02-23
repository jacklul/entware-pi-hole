#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PREFIX="$1"
TARGET="$2"

if [ -z "$PREFIX" ] || [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
    echo "Usage: $0 <file prefix> <repository path> [no-patches/no-checks]"
    exit 1
fi

TARGET="$(realpath "$TARGET")"
PREFIX="${PREFIX,,}" # Force prefix to be lowercase
BRANCH=$(git -C "$TARGET" rev-parse --abbrev-ref HEAD)

if [ "$3" != "no-patches" ]; then
    PATCHES_DIR="$(readlink -f "$SCRIPT_DIR/../patches")"

    FILES="$(find "$PATCHES_DIR" -maxdepth 1 -type f \( -name "$PREFIX-*.patch" -or -name "$PREFIX-*.diff" \) | sort)"
    for FILE in $FILES; do
        BASENAME="$(basename "$FILE")"

        # if the same FILE exists in BRANCH subdirectory then use it instead
        if [ -f "$PATCHES_DIR/$BRANCH/$BASENAME" ]; then
            FILE="$PATCHES_DIR/$BRANCH/$BASENAME"
        fi

        echo "Applying patch file: $FILE"
        git -C "$TARGET" apply -v "$FILE" || exit 1
        echo ""
    done

    FILES="$(find "$PATCHES_DIR" -maxdepth 1 -type f -name "$PREFIX-*.sh" | sort)"
    for FILE in $FILES; do
        # if the same FILE exists in BRANCH subdirectory then use it instead
        if [ -f "$PATCHES_DIR/$BRANCH/$BASENAME" ]; then
            FILE="$PATCHES_DIR/$BRANCH/$BASENAME"
        fi

        echo "Running patch script: $FILE"
        bash "$FILE" "$TARGET" || exit 1
        echo ""
    done

    echo "All patches applied"
    echo ""
fi

if [ "$3" != "no-checks" ]; then
    CHECKS_DIR="$(readlink -f "$SCRIPT_DIR/../checks")"

    FILES="$(find "$CHECKS_DIR" -maxdepth 1 -type f -name "$PREFIX-*.sh" | sort)"
    for FILE in $FILES; do
        echo "Running check script: $FILE"
        bash "$FILE" "$TARGET" || exit 1
        echo ""
    done

    echo "All checks passed"
    echo ""
fi

exit 0
