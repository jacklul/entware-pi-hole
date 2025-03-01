#!/usr/bin/env bash
# Make sure sockstat calls have not changed

#shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common-core.sh"

find1="tput colors"
find2="tput civis"
find3="tput cnorm"
found1=false
found2=false
found3=false

[ -z "$FILES" ] && exit 1
for file in $FILES; do
    { [ ! -f "$file" ] || { [ "$(head -c 3 "$file")" != "#!/" ] && ! grep -q '; then' "$file" ; } ; } && continue

    echo "Checking $file..."

    # No comments
    contents="$(grep -o "^[^#]*" < "$file"))"

    # Checks
    if echo "$contents" | grep -qaE "$find1"; then
        found1=true
        contents="$(echo "$contents" | grep -av "$find1")" # /advanced/Scripts/COL_TABLE
    fi

    if echo "$contents" | grep -qaE "$find2"; then
        found2=true
        contents="$(echo "$contents" | grep -av "$find2")" # /advanced/Scripts/piholeDebug.sh
    fi

    if echo "$contents" | grep -qaE "$find3"; then
        found3=true
        contents="$(echo "$contents" | grep -av "$find3")" # /advanced/Scripts/piholeDebug.sh
    fi

    echo "$contents" | grep -aEn "\s+tput [[:alnum:]_]+" && exit 1
done

if [ "$found1" = false ] || [ "$found2" = false ] || [ "$found3" = false ]; then
    echo "'$find1' = $found1"
    echo "'$find2' = $found2"
    echo "'$find3' = $found3"
    exit 1
fi

exit 0
