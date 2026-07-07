#!/usr/bin/env bash
# Make sure there is no script requiring basic-install.sh

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || [ "$(head -c 3 "$file")" != "#!/" ] ; } && continue

    basename="$(basename "$file")"

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Exceptions (@TODO the way these are handled needs to be improved)

    if [ "$basename" = "pihole" ]; then
        contents="$(echo "$contents" | grep -aFv "/opt/share/pihole/basic-install.sh --repair")" # /pihole
    fi

    # Checks
    echo "$contents" | grep -aFn "/opt/share/pihole/basic-install.sh" && exit 1
done

exit 0
