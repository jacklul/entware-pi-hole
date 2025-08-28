#!/usr/bin/env bash
# Make sure sockstat calls have not changed

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || [ "$(head -c 3 "$file")" != "#!/" ] ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Exceptions (@TODO the way these are handled needs to be improved)
    contents="$(echo "$contents" | grep -aFv "getent hosts")" # /gravity.sh

    # Checks
    echo "$contents" | grep -aEn "getent [[:alnum:]_]+ " && exit 1
done

exit 0
