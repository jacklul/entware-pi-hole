#!/bin/bash

if [ -z "$1" ]; then
    echo "TARGET_DIR is not set"
    exit 1
fi

#shellcheck disable=SC2155,SC2034
readonly TARGET_DIR="$(readlink -f "$1")"

#shellcheck disable=SC2162,SC2034
read -d '\n' FILES << EOF
$(find "$TARGET_DIR" \
    -type f \
    -name "*" \
    -not -name ".*" \
    -not -path "$TARGET_DIR/.*" \
    -not -path "$TARGET_DIR/automated install/*" \
    -not -name "pihole-FTL.service" \
| sort)
EOF
