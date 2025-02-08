#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DESTINATION_DIR="$1"
SEARCH_DIR="$2"

################

set -e

[ -z "$DESTINATION_DIR" ] && { echo "Error: Destination directory not provided"; exit 1; }
[ ! -d "$DESTINATION_DIR" ] && { echo "Error: Directory $DESTINATION_DIR does not exist"; exit 1; }
[ -z "$SEARCH_DIR" ] && SEARCH_DIR="$(dirname "$SCRIPT_DIR")"

DESTINATION_DIR="$(realpath "$DESTINATION_DIR")"
SEARCH_DIR="$(realpath "$SEARCH_DIR")"

CORE_PATH="$(find "$SEARCH_DIR" -type f -name "gravity.sh" -print -quit)"
WEB_PATH="$(find "$SEARCH_DIR" -type f -name "index.lp" -print -quit)"
FTL_PATH="$(find "$SEARCH_DIR" -type f -name "pihole-FTL" -print -quit)"

[ -z "$CORE_PATH" ] && { echo "Error: Could not find Pi-hole's core directory"; exit 1; }
[ -z "$WEB_PATH" ] && { echo "Error: Could not find Pi-hole's web directory"; exit 1; }
[ -z "$FTL_PATH" ] && { echo "Error: Could not find Pi-hole's FTL binary"; exit 1; }

ROOT_PATH="$(readlink -f "$(dirname "$SCRIPT_DIR")")"
CORE_PATH="$(readlink -f "$(dirname "$CORE_PATH")")"
WEB_PATH="$(readlink -f "$(dirname "$WEB_PATH")")"
FTL_PATH="$(readlink -f "$(dirname "$FTL_PATH")")"

mkdir -p "$DESTINATION_DIR/opt"/{bin,etc/{pihole,cron.d,dnsmasq.d},share/pihole,var/log/pihole}

if [ -z "$(ls -A "$DESTINATION_DIR/opt/share/pihole")" ]; then
    echo "Copying scripts and other essential files..."
    cp -nr "$CORE_PATH/advanced/Scripts"/* "$DESTINATION_DIR/opt/share/pihole"
    cp -n "$CORE_PATH/advanced/Templates"/*.sh "$DESTINATION_DIR/opt/share/pihole"
    cp -n "$CORE_PATH/advanced/Templates"/*.sql "$DESTINATION_DIR/opt/share/pihole"
    cp -n "$CORE_PATH/gravity.sh" "$DESTINATION_DIR/opt/share/pihole/gravity.sh"
fi

if [ -z "$(ls -A "$DESTINATION_DIR/opt/etc/pihole")" ] || [ -z "$(ls -A "$DESTINATION_DIR/opt/etc/cron.d")" ]; then
    echo "Copying configuration files..."
    [ -f "$CORE_PATH/advanced/Templates/pihole-FTL.conf" ] && cp -n "$CORE_PATH/advanced/Templates/pihole-FTL.conf" "$DESTINATION_DIR/opt/etc/pihole/pihole-FTL.conf"
    [ -f "$CORE_PATH/advanced/Templates/pihole.cron" ] && cp -n "$CORE_PATH/advanced/Templates/pihole.cron" "$DESTINATION_DIR/opt/etc/cron.d/pihole"
    [ -f "$CORE_PATH/advanced/Templates/logrotate" ] && cp -n "$CORE_PATH/advanced/Templates/logrotate" "$DESTINATION_DIR/opt/etc/pihole"
fi

if [ ! -d "$DESTINATION_DIR/opt/share/pihole/www/admin" ]; then
    echo "Copying web files..."
    mkdir -p "$DESTINATION_DIR/opt/share/pihole/www/admin"
    cp -nr "$WEB_PATH"/* "$DESTINATION_DIR/opt/share/pihole/www/admin"
    rm -f "$DESTINATION_DIR/opt/share/pihole/www/admin"/*.md
    rm -f "$DESTINATION_DIR/opt/share/pihole/www/admin"/*.json
fi

if [ ! -f "$DESTINATION_DIR/opt/bin/pihole" ]; then
    echo "Copying 'pihole' script..."
    cp -n "$CORE_PATH/pihole" "$DESTINATION_DIR/opt/bin/pihole"
fi

if [ ! -f "$DESTINATION_DIR/opt/bin/pihole-FTL" ]; then
    echo "Copying FTL binary..."
    cp -n "$FTL_PATH/pihole-FTL" "$DESTINATION_DIR/opt/bin/pihole-FTL"
fi

echo "Copying files from 'files' directory..."
cp -nr "$ROOT_PATH/files"/* "$DESTINATION_DIR"

if [ ! -f "$DESTINATION_DIR/opt/etc/pihole/macvendor.db" ]; then
    echo "Downloading macvendor.db..."

    if ! curl -sSL "https://ftl.pi-hole.net/macvendor.db" -o "$DESTINATION_DIR/opt/etc/pihole/macvendor.db"; then
        echo "Error: Could not download macvendor.db"
        exit 1
    fi
fi

if [ ! -f "$DESTINATION_DIR/opt/etc/pihole/versions" ]; then
    echo "Creating versions file..."

    for PART in CORE WEB FTL; do
        PART_PATH="${PART}_PATH"

        if [ -d "${!PART_PATH}" ] && [ -f "${!PART_PATH}/.version" ]; then
            #shellcheck disable=SC1091
            . "${!PART_PATH}/.version"

            {
                echo "${PART}_VERSION=$VERSION"
                echo "${PART}_BRANCH=$BRANCH"
                echo "${PART}_HASH=$HASH"
            } >> "$DESTINATION_DIR/opt/etc/pihole/versions"
        fi
    done
fi

#shellcheck disable=SC2034
SKIP_INSTALL=true # Allows sourcing installer without running it
#shellcheck disable=SC1091
source "$CORE_PATH/automated install/basic-install.sh"

if [ ! -f "$DESTINATION_DIR/opt/etc/pihole/dns-servers.conf" ]; then
    echo "Creating dns-servers.conf file..."

    if [ -z "$DNS_SERVERS" ]; then
        echo "Error: Could not load DNS_SERVERS variable from basic-install.sh"
        exit 1
    fi

    echo "$DNS_SERVERS" > "$DESTINATION_DIR/opt/etc/pihole/dns-servers.conf"
fi

if [ ! -f "$DESTINATION_DIR/opt/etc/pihole/adlists.list" ]; then
    echo "Creating adlists.list file..."

    #shellcheck disable=SC2034
    adlistFile="$DESTINATION_DIR/opt/etc/pihole/adlists.list"

    if ! installDefaultBlocklists; then
        echo "Error: Could not install default adlists using basic-install.sh"
        exit 1
    fi
fi

echo "Setting permissions..."
find "$DESTINATION_DIR" -type f -exec chmod 0644 {} \;
find "$DESTINATION_DIR" -type d -exec chmod 0755 {} \;
chmod 755 "$DESTINATION_DIR/opt/bin"/* "$DESTINATION_DIR/opt/etc/init.d"/*
find "$DESTINATION_DIR/opt/share/pihole" -type f \( -name "*.sh" -o -name "COL_TABLE" \) -exec chmod 0755 {} \;
find "$DESTINATION_DIR/opt/share/pihole/polyfill" -type f -exec chmod 0755 {} \;

echo "Created package files in $DESTINATION_DIR"
