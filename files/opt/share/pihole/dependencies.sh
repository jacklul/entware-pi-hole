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
    ["pwd"]="coreutils-pwd"
    ["readlink"]="coreutils-readlink"
    ["rm"]="coreutils-rm"
    ["sha1sum"]="coreutils-sha1sum"
    ["sleep"]="coreutils-sleep"
    ["stat"]="coreutils-stat"
    ["tail"]="coreutils-tail"
    ["tee"]="coreutils-tee"
    ["timeout"]="coreutils-timeout"
    ["touch"]="coreutils-touch"
    ["tr"]="coreutils-tr"
    ["true"]="coreutils-true"
    ["wc"]="coreutils-wc"
    ["whoami"]="coreutils-whoami"
    ["rev"]="rev"
    #["lshw"]="lshw" # not available in Entware
    ["lscpu"]="lscpu"
)

# This array will contain packages that will be installed
TO_INSTALL=()

# Is this script running in an interactive shell?
INTERACTIVE=$([ "$(readlink -f /proc/$$/fd/0 2> /dev/null)" = "/dev/null" ] && echo false || echo true)

# Supress output if called with start or restart argument
SILENT=$([ "$1" = "silent" ] && echo true || echo false)

# Check only (nothing will be installed)
CHECK=$([ "$1" = "check" ] && echo true || echo false)

# Control file
CONTROL_FILE="/opt/lib/opkg/info/pi-hole.control"

#######################################

function cecho() {
    if [ "$INTERACTIVE" = true ] && [ "$SILENT" = false ]; then
        echo "$@" 2> /dev/null
    fi
}

if [ -f "$CONTROL_FILE" ]; then
    cecho "Checking for core dependencies..."

    DEPENDS="$(grep "^Depends:" < "$CONTROL_FILE" | sed -e "s/^[^:]*:[[:space:]]*//")"
    IFS=', ' read -r -a CORE_PACKAGES <<< "$DEPENDS"
    INSTALLED="$(opkg list-installed)"

    for CORE_PACKAGE in "${CORE_PACKAGES[@]}"; do
        cecho -n "- $CORE_PACKAGE"

        if ! echo "$INSTALLED" | grep -q "$CORE_PACKAGE -"; then
            cecho -n " ✗"

            if [ "$CHECK" = false ]; then
                cecho -n "   (will install '$CORE_PACKAGE' package)"
            fi

            TO_INSTALL+=("$CORE_PACKAGE")
        else
            cecho -n " ✓"
        fi

        cecho ""
    done
fi

cecho "Checking for scripting dependencies..."

for KEY in "${!DEPENDENCIES[@]}"; do
    cecho -n "- $KEY"

    if ! command -v "$KEY" &> /dev/null; then
        cecho -n " ✗"

        if [ "$CHECK" = false ]; then
            cecho -n "   (will install '${DEPENDENCIES[$KEY]}' package)"
        fi

        TO_INSTALL+=("${DEPENDENCIES[$KEY]}")
    else
        cecho -n " ✓"
    fi

    cecho ""
done

if [ "${#TO_INSTALL[@]}" -ne 0 ]; then
    if [ "$CHECK" = false ]; then
        cecho "Installing packages..."

        #shellcheck disable=SC2046
        opkg install "${TO_INSTALL[@]}" $([ "$SILENT" = true ] && echo "-V0") || exit 1
    else
        echo "Missing packages: ${TO_INSTALL[*]}"
        exit 1
    fi
fi

exit 0
