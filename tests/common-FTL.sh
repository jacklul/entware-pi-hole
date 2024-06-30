#!/bin/bash

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

#shellcheck disable=SC2162,SC2034
read -d '\n' FILES <<EOT
$(find "$TARGET_DIR" \
    -type f \
    \( \
        -path "$TARGET_DIR/src/*" \
        -a \( \
            -name "*.c" \
            -o -name "*.h" \
            -o -name "*.txt" \
            -o -name "*.sh" \
        \) \
        -o -path "$TARGET_DIR/test/*" \
        -a \( \
            -name "pihole.toml" \
        \) \
    \) \
    -not -path "$TARGET_DIR/src/api/docs/*" \
| sort)
EOT
