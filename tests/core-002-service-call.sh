#!/usr/bin/env bash
# Make sure there is no call to "service pihole-FTL" or "systemctl action pihole-FTL"

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for FILE in $FILES; do
    { [ ! -f "$FILE" ] || { [ "$(head -c 3 "$FILE")" != "#!/" ] && ! grep -q '; then' "$FILE" ; } ; } && continue

    echo "Checking $FILE..."

    # No comments
    CONTENTS="$(grep -o "^[^#]*" < "$FILE"))"

    # Checks
    echo "$CONTENTS" | grep -aEn "service pihole-FTL" && exit 1
    echo "$CONTENTS" | grep -aEn "service \"[[:alnum:]_]+\" status" && exit 1
    echo "$CONTENTS" | grep -aEn "systemctl [[:alnum:]_]+ pihole-FTL" && exit 1
done

exit 0
