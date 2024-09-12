#!/usr/bin/env bash
# Make sure sockstat calls have not changed

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

find1="getent hosts"
found1=false

[ -z "$FILES" ] && exit 1
for FILE in $FILES; do
    { [ ! -f "$FILE" ] || { [ "$(head -c 3 "$FILE")" != "#!/" ] && ! grep -q '; then' "$FILE" ; } ; } && continue

    echo "Checking $FILE..."

    # No comments
    CONTENTS="$(grep -o "^[^#]*" < "$FILE"))"

    # Checks
    if echo "$CONTENTS" | grep -qaE "$find1"; then
        found1=true
        CONTENTS="$(echo "$CONTENTS" | grep -av "$find1")" # /gravity.sh
    fi

    echo "$CONTENTS" | grep -aEn "getent [[:alnum:]_]+ " && exit 1
done

if [ "$found1" = false ]; then
    echo "'$find1' = $found1"
    exit 1
fi

exit 0
