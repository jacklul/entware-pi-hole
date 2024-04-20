#!/bin/bash
# Make sure all referenced paths are not pointing to non-/opt directories

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-FTL.sh"

[ -z "$FILES" ] && exit 1
for FILE in $FILES; do
    [ ! -f "$FILE" ] && continue

    FILENAME=$(basename -- "$FILE")
    EXTENSION="${FILENAME##*.}"
    FILENAME="${FILENAME%.*}"

    echo "Checking $FILE..."

    # No comments
    if [ "$EXTENSION" = "sh" ] || [ "$EXTENSION" = "txt" ]; then
        CONTENTS="$(grep -Ev "^(\s*#)" < "$FILE")"
    else
        CONTENTS="$(grep -Ev "^(\s*//|\s*/\*|\s*\*|\s*\*/)" < "$FILE")"
    fi

    # Exceptions (@TODO the way these are handled needs to be improved)
    CONTENTS="$(echo "$CONTENTS" | grep -av "\/etc\/hosts" | grep -av "/etc/ethers" | grep -av "/etc/resolv.conf" | grep -av "/etc/hostname" | grep -av "find_library" | grep -av "CMAKE_INSTALL_PREFIX" | grep -av "/etc/config/resolv.conf" | grep -av "/var/db/dnsmasq.leases" | grep -av "/var/cache/dnsmasq.leases" | grep -av "/usr/local/etc/dnsmasq.conf" | grep -av "LUA_ROOT" | grep -av "/src/lua" | grep -av "       \"document_root\", \"/var/www\",")"

    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/etc" && exit 1
    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/var" && exit 1
    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/usr" && exit 1
    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/tmp" && exit 1
    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/run" && exit 1
    echo -e "$CONTENTS" | grep -aE "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
