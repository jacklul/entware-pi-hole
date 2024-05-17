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
        #CONTENTS="$(grep -Ev "^(\s*//|\s*/\*|\s*\*|\s*\*/)" < "$FILE")"

        CONTENTS="$(cat "$FILE" | awk '
BEGIN { multi_line_comment = 0 }
{
    while (match($0, /\/\*[^*]*\*\//)) {
        $0 = substr($0, 1, RSTART-1) substr($0, RSTART+RLENGTH)
    }
    while (match($0, /\/\*/)) {
        multi_line_comment = 1
        $0 = substr($0, 1, RSTART-1)
        rest_of_line = substr($0, RSTART+RLENGTH)
        while (multi_line_comment && getline > 0) {
            if (match($0, /\*\//)) {
                $0 = substr($0, RSTART+RLENGTH)
                multi_line_comment = 0
            }
        }
        $0 = rest_of_line $0
    }
    if (!multi_line_comment) {
        sub(/\/\/.*/, "")
        print
    }
}')"
    fi

    # Exceptions (@TODO the way these are handled needs to be improved)
    CONTENTS="$(echo "$CONTENTS" | grep -av "HINTS /usr/local/lib64")" # /src/CMakeLists.txt
    CONTENTS="$(echo "$CONTENTS" | grep -av "CMAKE_INSTALL_PREFIX \"/usr\"")" # /src/CMakeLists.txt
    CONTENTS="$(echo "$CONTENTS" | grep -av "/etc/hostname")" # src/config/config.c
    CONTENTS="$(echo "$CONTENTS" | grep -av "/etc/config/resolv.conf")" # src/dnsmasq/config.h
    CONTENTS="$(echo "$CONTENTS" | grep -av "/usr/local/etc/dnsmasq.conf")" # src/dnsmasq/config.h
    CONTENTS="$(echo "$CONTENTS" | grep -av "/var/cache/dnsmasq.leases")" # src/dnsmasq/config.h
    CONTENTS="$(echo "$CONTENTS" | grep -av "/var/db/dnsmasq.leases")" # src/dnsmasq/config.h
    CONTENTS="$(echo "$CONTENTS" | grep -av "\${PROJECT_SOURCE_DIR}/src/lua /usr/local/include")" # src/webserver/civetweb/CMakeLists.txt
    CONTENTS="$(echo "$CONTENTS" | grep -av "LUA_ROOT	\"/usr/local/\"")" # src/lua/luaconf.h
    CONTENTS="$(echo "$CONTENTS" | grep -av "Failed to add /etc/hosts")" # src/zip/teleporter.c @TODO this is a mistake on devs side

    # Checks
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/etc" && exit 1
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/var" && exit 1
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/usr" && exit 1
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/tmp" && exit 1
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/run" && exit 1
    echo -e "$CONTENTS" | grep -aEn "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
