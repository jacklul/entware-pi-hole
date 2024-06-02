#!/bin/bash

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

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
