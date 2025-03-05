#!/usr/bin/env bash
# Make sure there is no call to "service pihole-FTL" or "systemctl action pihole-FTL"

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || { [ "$(head -c 3 "$file")" != "#!/" ] && ! grep -q '; then' "$file" ; } ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Exceptions (@TODO the way these are handled needs to be improved)
    contents="$(echo "$contents" | grep -aFv "systemctl status --full --no-pager pihole-FTL.service")" # /advanced/Scripts/piholeDebug.sh

    # Checks
    echo "$contents" | grep -aFn "service pihole-FTL" && exit 1
    echo "$contents" | grep -aEn "service \"[[:alnum:]_]+\" status" && exit 1
    echo "$contents" | grep -aEn "systemctl [a-zA-Z0-9 _-]+ pihole-FTL" && exit 1
done

exit 0
