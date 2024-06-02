#!/bin/bash

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

#shellcheck disable=SC2162,SC2034
read -d '\n' FILES <<EOT
$(find "$TARGET_DIR" \
    -type f \
    -name "*" \
    -not -name ".*" \
    -not -path "$TARGET_DIR/.*" \
    -not -path "$TARGET_DIR/automated install/*" \
    -not -name "pihole-FTL.service" \
| sort)
EOT
