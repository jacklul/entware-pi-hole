#!/usr/bin/env bash
# Make sure all referenced paths are not pointing to non-/opt directories

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-FTL.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    [ ! -f "$file" ] && continue

    filename=$(basename -- "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    basename="$(basename "$file")"

    echo "Checking $file..."

    # No comments
    if [ "$extension" = "sh" ] || [ "$extension" = "txt" ]; then
        contents="$(grep -Ev "^(\s*#)" < "$file")"
    else
        #contents="$(grep -Ev "^(\s*//|\s*/\*|\s*\*|\s*\*/)" < "$file")"

        contents="$(awk '
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
}' < "$file")"
    fi

    # Exceptions (@TODO the way these are handled needs to be improved)

    if [ "$basename" = "CMakeLists.txt" ]; then
        contents="$(echo "$contents" | grep -aFv "HINTS /usr/local/lib64")" # /src/CMakeLists.txt
        contents="$(echo "$contents" | grep -aFv "CMAKE_INSTALL_PREFIX \"/usr\"")" # /src/CMakeLists.txt
        contents="$(echo "$contents" | grep -aFv "\${PROJECT_SOURCE_DIR}/src/lua /usr/local/include")" # /src/webserver/civetweb/CMakeLists.txt
    fi

    if [ "$basename" = "args.c" ]; then
        contents="$(echo "$contents" | grep -aFv "%s --gen-x509")" # /src/args.c
        contents="$(echo "$contents" | grep -aFv "%s %s /etc/")" # /src/args.c
    fi

    if [ "$basename" = "config.c" ]; then
        contents="$(echo "$contents" | grep -aFv "/etc/hostname")" # /src/config/config.c
        contents="$(echo "$contents" | grep -aEv 'conf->[A-Za-z0-9._]+\.h')" # config comments in /src/config/config.c
    fi

    if [ "$basename" = "dnsmasq_config.c" ]; then
        contents="$(echo "$contents" | grep -aEv '^[[:space:]]*fputs\("#')" # dnsmasq config comments in /src/config/dnsmasq_config.c
        contents="$(echo "$contents" | grep -aFv "HEADER_WIDTH, \"%s\"")" # /src/config/dnsmasq_config.c
    fi

    if [ "$basename" = "config.h" ]; then
        contents="$(echo "$contents" | grep -aFv "/etc/config/resolv.conf")" # /src/dnsmasq/config.h
        contents="$(echo "$contents" | grep -aFv "/usr/local/etc/dnsmasq.conf")" # /src/dnsmasq/config.h
        contents="$(echo "$contents" | grep -aFv "/var/cache/dnsmasq.leases")" # /src/dnsmasq/config.h
        contents="$(echo "$contents" | grep -aFv "/var/db/dnsmasq.leases")" # /src/dnsmasq/config.h
    fi

    if [ "$basename" = "option.c" ]; then
        contents="$(echo "$contents" | grep -aFv "Expand simple names in /etc/hosts with domain-suffix")" # /src/dnsmasq/option.c
        contents="$(echo "$contents" | grep -aFv "Specify time-to-live in seconds for replies from /etc/hosts")" # /src/dnsmasq/option.c
    fi

    if [ "$basename" = "luaconf.h" ]; then
        contents="$(echo "$contents" | grep -aFv "LUA_ROOT	\"/usr/local/\"")" # /src/lua/luaconf.h
    fi

    if [ "$basename" = "x509.c" ]; then
        contents="$(echo "$contents" | grep -aFv "read_id_file(\"/etc/machine-id\", machine_id")" # /src/webserver/x509.c
    fi

    if [ "$basename" = "pihole.toml" ]; then
        contents="$(echo "$contents" | grep -aEv '^[[:space:]]*#')" # /test/pihole.toml
        contents="$(echo "$contents" | grep -aFv "/etc/pihole/test.pem\" ### CHANGED")" # /test/pihole.toml
    fi

    if [ "$basename" = "test_suite.bats" ]; then
        contents="$(echo "$contents" | grep -aFv "SQLite 3.x database")" # /test/test_suite.bats
        contents="$(echo "$contents" | grep -aFv "Reading certificate from")" # /test/test_suite.bats
    fi

    # Checks
    echo -e "$contents" | grep -aEn "(^|\s+|\")/etc" && exit 1
    echo -e "$contents" | grep -aEn "(^|\s+|\")/var" && exit 1
    echo -e "$contents" | grep -aEn "(^|\s+|\")/usr" && exit 1
    echo -e "$contents" | grep -aEn "(^|\s+|\")/tmp" && exit 1
    echo -e "$contents" | grep -aEn "(^|\s+|\")/run" && exit 1
    echo -e "$contents" | grep -aEn "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
