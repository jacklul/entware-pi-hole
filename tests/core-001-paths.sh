#!/bin/bash
# Make sure all referenced paths are not pointing to non-/opt directories

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for FILE in $FILES; do
    { [ ! -f "$FILE" ] || [ "$(head -c 3 "$FILE")" != "#!/" ] ; } && continue

    echo "Checking $FILE..."

    # No comments
    CONTENTS="$(grep -o "^[^#]*" < "$FILE")"

    # Exceptions (@TODO the way these are handled needs to be improved)
    CONTENTS="$(echo "$CONTENTS" | grep -av "\/etc\/os-release" | grep -av "\/etc\/\*release" | grep -av "\/etc\/selinux" | grep -av "show_content_of_files_in_dir")"

    echo "$CONTENTS" | grep -aE "(^|\s+|\")/etc" && exit 1
    echo "$CONTENTS" | grep -aE "(^|\s+|\")/var" && exit 1
    echo "$CONTENTS" | grep -aE "(^|\s+|\")/usr" && exit 1
    echo "$CONTENTS" | grep -aE "(^|\s+|\")/tmp" && exit 1
    echo "$CONTENTS" | grep -aE "(^|\s+|\")/run" && exit 1
    echo "$CONTENTS" | grep -aE "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
