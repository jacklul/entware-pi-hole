#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

cd "$(dirname "$SCRIPT_DIR")" || exit 1

"$SCRIPT_DIR/dev.sh" "$1" all

"$SCRIPT_DIR/patch.sh" core dev/core
"$SCRIPT_DIR/version.sh" dev/core

"$SCRIPT_DIR/patch.sh" web dev/web
"$SCRIPT_DIR/version.sh" dev/web

"$SCRIPT_DIR/patch.sh" FTL dev/FTL
"$SCRIPT_DIR/version.sh" dev/FTL

"$SCRIPT_DIR/test.sh" core dev/core
"$SCRIPT_DIR/test.sh" web dev/web
"$SCRIPT_DIR/test.sh" FTL dev/FTL
