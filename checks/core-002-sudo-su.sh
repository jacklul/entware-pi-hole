#!/usr/bin/env bash
# Make sure there are no calls to sudo or su

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || [ "$(head -c 3 "$file")" != "#!/" ] ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Exceptions (@TODO the way these are handled needs to be improved)
    contents="$(echo "$contents" | grep -aFv "Try with sudo power")" # /advanced/Scripts/utils.sh

    # Checks
    echo "$contents" | grep -aFn "sudo " && exit 1
    echo "$contents" | grep -aFn "su " && exit 1
done

exit 0
