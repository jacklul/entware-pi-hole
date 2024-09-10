#!/usr/bin/env bash
# Make sure all referenced paths are not pointing to non-/opt directories

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for FILE in $FILES; do
    { [ ! -f "$FILE" ] || { [ "$(head -c 3 "$FILE")" != "#!/" ] && ! grep -q '; then' "$FILE" ; } ; } && continue

    echo "Checking $FILE..."

    # No comments
    CONTENTS="$(grep -o "^[^#]*" < "$FILE")"

    # Exceptions (@TODO the way these are handled needs to be improved)
    CONTENTS="$(echo "$CONTENTS" | grep -av "\/etc\/os-release\|\/etc\/\*release\|\/etc\/selinux")" # advanced/Scripts/piholeDebug.sh

    # Checks
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/etc" && exit 1
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/var" && exit 1
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/usr" && exit 1
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/tmp" && exit 1
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/run" && exit 1
    echo "$CONTENTS" | grep -aEn "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
