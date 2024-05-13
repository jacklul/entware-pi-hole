#!/bin/bash

#shellcheck disable=SC2155
readonly TARGET_DIR="$(readlink -f "$1")"

rm -fv "$TARGET_DIR/advanced/Scripts/piholeCheckout.sh"
rm -fv "$TARGET_DIR/advanced/Scripts/update.sh"
