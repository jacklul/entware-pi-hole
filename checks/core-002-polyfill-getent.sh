#!/usr/bin/env bash
# Make sure sockstat calls have not changed

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

find1="getent hosts"
found1=false

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || { [ "$(head -c 3 "$file")" != "#!/" ] && ! grep -q '; then' "$file" ; } ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Checks
    if echo "$contents" | grep -qaE "$find1"; then
        found1=true
        contents="$(echo "$contents" | grep -aFv "$find1")" # /gravity.sh
    fi

    echo "$contents" | grep -aEn "getent [[:alnum:]_]+ " && exit 1
done

if [ "$found1" = false ]; then
    echo "'$find1' = $found1"
    exit 1
fi

exit 0
