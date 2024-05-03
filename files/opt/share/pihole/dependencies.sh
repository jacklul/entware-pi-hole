#!/usr/bin/env bash
# This script is part of https://github.com/jacklul/entware-pi-hole
# It will install any missing dependencies required by Pi-hole scripts
# It is automatically executed by init.d script

# This array contains command => Entware package name definition
declare -A DEPENDENCIES=(
    ["basename"]="coreutils-basename"
    ["cat"]="coreutils-cat"
    ["chmod"]="coreutils-chmod"
    ["chown"]="coreutils-chown"
    ["cp"]="coreutils-cp"
    ["cut"]="coreutils-cut"
    ["date"]="coreutils-date"
    ["dirname"]="coreutils-dirname"
    ["echo"]="coreutils-echo"
    ["expr"]="coreutils-expr"
    ["false"]="coreutils-false"
    ["head"]="coreutils-head"
    ["id"]="coreutils-id"
    ["install"]="coreutils-install"
    ["kill"]="coreutils-kill"
    ["ln"]="coreutils-ln"
    ["mkdir"]="coreutils-mkdir"
    ["mktemp"]="coreutils-mktemp"
    ["mv"]="coreutils-mv"
    ["nohup"]="coreutils-nohup"
    ["printf"]="coreutils-printf"
    ["rm"]="coreutils-rm"
    ["sha1sum"]="coreutils-sha1sum"
    ["sleep"]="coreutils-sleep"
    ["stat"]="coreutils-stat"
    ["tail"]="coreutils-tail"
    ["timeout"]="coreutils-timeout"
    ["touch"]="coreutils-touch"
    ["tr"]="coreutils-tr"
    ["true"]="coreutils-true"
    ["wc"]="coreutils-wc"
    ["whoami"]="coreutils-whoami"
)

# This array will contain packages that will be installed
TO_INSTALL=()

# Is this script running in an interactive shell?
INTERACTIVE=$([ "$(readlink -f /proc/$$/fd/0 2> /dev/null)" = "/dev/null" ] && echo false || echo true)

# Supress output if called with start or restart argument
SILENT=$([ "$1" = "silent" ] && echo true || echo false)

function cecho() {
    if [ "$INTERACTIVE" = true ] && [ "$SILENT" = false ]; then
        echo "$@" 2> /dev/null
    fi
}

cecho "Checking for dependencies..."

for KEY in "${!DEPENDENCIES[@]}"; do
    cecho -n "- $KEY"

    if ! command -v "$KEY" &> /dev/null; then
        cecho " ✗   (will install '${DEPENDENCIES[$KEY]}' package)"

        TO_INSTALL+=("${DEPENDENCIES[$KEY]}")
    else
        cecho " ✓"
    fi
done

if [ "${#TO_INSTALL[@]}" -ne 0 ]; then
    cecho "Installing packages..."

    opkg install "${TO_INSTALL[@]}" || exit 1
fi

exit 0
