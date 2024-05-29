#!/bin/bash

if [ -z "$1" ]; then
    echo "TARGET_DIR is not set"
    exit 1
fi

#shellcheck disable=SC2155,SC2034
readonly TARGET_DIR="$(readlink -f "$1")"

#shellcheck disable=SC2162,SC2034
read -d '\n' FILES <<EOT
$(find "$TARGET_DIR/src" \
    -type f \
    \( \
        -name "*.c" \
        -o -name "*.h" \
        -o -name "*.sh" \
        -o -name "*.txt" \
    \) \
    -not -path "$TARGET_DIR/src/test/*" \
    -not -path "$TARGET_DIR/src/api/docs/*" \
| sort)
EOT
