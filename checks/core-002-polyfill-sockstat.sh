#!/usr/bin/env bash
# Make sure sockstat calls have not changed

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

find1="ss --listening --numeric --tcp --udp --processes --no-header"
find2="ss --ipv4 --listening --numeric --tcp --udp src"
find3="ss --ipv6 --listening --numeric --tcp --udp src"
found1=false
found2=false
found3=false

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || { [ "$(head -c 3 "$file")" != "#!/" ] && ! grep -q '; then' "$file" ; } ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Checks
    if echo "$contents" | grep -qaE "$find1"; then
        found1=true
        contents="$(echo "$contents" | grep -aFv "$find1")" # /advanced/Scripts/piholeDebug.sh
    fi

    if echo "$contents" | grep -qaE "$find2"; then
        found2=true
        contents="$(echo "$contents" | grep -aFv "$find2")" # /pihole
    fi

    if echo "$contents" | grep -qaE "$find3"; then
        found3=true
        contents="$(echo "$contents" | grep -aFv "$find3")" # /pihole
    fi

    echo "$contents" | grep -aEn "ss --" && exit 1
done

if [ "$found1" = false ] || [ "$found2" = false ] || [ "$found3" = false ]; then
    echo "'$find1' = $found1"
    echo "'$find2' = $found2"
    echo "'$find3' = $found3"
    exit 1
fi

exit 0
