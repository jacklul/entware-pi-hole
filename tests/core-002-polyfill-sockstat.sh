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
for FILE in $FILES; do
    { [ ! -f "$FILE" ] || { [ "$(head -c 3 "$FILE")" != "#!/" ] && ! grep -q '; then' "$FILE" ; } ; } && continue

    echo "Checking $FILE..."

    # No comments
    CONTENTS="$(grep -o "^[^#]*" < "$FILE"))"

    foundhere=false

    # Checks
    echo "$CONTENTS" | grep -qaE "$find1" && found1=true && foundhere=true
    echo "$CONTENTS" | grep -qaE "$find2" && found2=true && foundhere=true
    echo "$CONTENTS" | grep -qaE "$find3" && found3=true && foundhere=true

    [ "$foundhere" = true ] && continue
    echo "$CONTENTS" | grep -aE "ss --" && exit 1
done

if [ "$found1" = false ] || [ "$found2" = false ] || [ "$found3" = false ]; then
    echo "'$find1' = $found1"
    echo "'$find2' = $found2"
    echo "'$find3' = $found3"
    exit 1
fi

exit 0
