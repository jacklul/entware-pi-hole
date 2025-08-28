#!/usr/bin/env bash

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

#shellcheck disable=SC2162,SC2034
read -d '\n' FILES <<EOT
$(find "$TARGET_DIR" \
    -type f \
    -name "*" \
    -not -name ".*" \
    -not -name "LICENSE" \
    -not -name "*.md" \
    -not -path "$TARGET_DIR/.*" \
    -not -path "$TARGET_DIR/automated install/*" \
    -not -path "$TARGET_DIR/advanced/bash-completion/*" \
    -not -path "$TARGET_DIR/advanced/Scripts/database_migration/gravity/*" \
    -not -path "$TARGET_DIR/test/*" \
    -not -path "$TARGET_DIR/manpages/*" \
    -not -name "pihole-FTL.systemd" \
    -not -name "pihole-FTL.service" \
    -not -name "pihole-FTL.openrc" \
| sort)
EOT
