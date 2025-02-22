#!/usr/bin/env bash
# Make sure the license version is correct

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

LICENSE_LINE="EUROPEAN UNION PUBLIC LICENCE v. 1.2"

if [ ! -f "$TARGET_DIR/LICENSE" ]; then
    echo "ERROR: No LICENSE file found in $TARGET_DIR"
    exit 1
fi

if ! grep -q "$LICENSE_LINE" "$TARGET_DIR/LICENSE"; then
    echo "ERROR: LICENSE file does not contain the correct license string"
    exit 1
fi

exit 0
