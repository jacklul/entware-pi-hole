#!/usr/bin/env bash
# Make sure all referenced paths are not pointing to non-/opt directories

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || { [ "$(head -c 3 "$file")" != "#!/" ] && ! grep -q '; then' "$file" ; } ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file")"

    # Exceptions (@TODO the way these are handled needs to be improved)
    contents="$(echo "$contents" | grep -av "\/etc\/os-release\|\/etc\/\*release\|\/etc\/selinux")" # advanced/Scripts/piholeDebug.sh

    # Checks
    echo "$contents" | grep -aEn "(^|\s+|\")/etc" && exit 1
    echo "$contents" | grep -aEn "(^|\s+|\")/var" && exit 1
    echo "$contents" | grep -aEn "(^|\s+|\")/usr" && exit 1
    echo "$contents" | grep -aEn "(^|\s+|\")/tmp" && exit 1
    echo "$contents" | grep -aEn "(^|\s+|\")/run" && exit 1
    echo "$contents" | grep -aEn "(^|\s+|\")/opt/pihole" && exit 1
done

exit 0
