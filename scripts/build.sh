#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
destination_dir="$1"
search_dir="$2"

################

set -e

[ -z "$destination_dir" ] && { echo "Error: Destination directory not provided"; exit 1; }
[ ! -d "$destination_dir" ] && { echo "Error: Directory $destination_dir does not exist"; exit 1; }
[ -z "$search_dir" ] && search_dir="$(dirname "$script_dir")"

destination_dir="$(realpath "$destination_dir")"
search_dir="$(realpath "$search_dir")"

core_path="$(find "$search_dir" -type f -name "gravity.sh" -print -quit)"
web_path="$(find "$search_dir" -type f -name "index.lp" -print -quit)"
ftl_path="$(find "$search_dir" -type f -name "pihole-FTL" -size +1M -print -quit)"

[ -z "$core_path" ] && { echo "Error: Could not find Pi-hole's core directory"; exit 1; }
[ -z "$web_path" ] && { echo "Error: Could not find Pi-hole's web directory"; exit 1; }
[ -z "$ftl_path" ] && { echo "Error: Could not find Pi-hole's FTL binary"; exit 1; }

root_path="$(readlink -f "$(dirname "$script_dir")")"
core_path="$(readlink -f "$(dirname "$core_path")")"
web_path="$(readlink -f "$(dirname "$web_path")")"
ftl_path="$(readlink -f "$(dirname "$ftl_path")")"

mkdir -p "$destination_dir/opt"/{bin,etc/{pihole,cron.d,dnsmasq.d},share/pihole,var/log/pihole}

if [ -z "$(ls -A "$destination_dir/opt/share/pihole")" ]; then
    echo "Copying core files..."
    cp -r --update=none "$core_path/advanced/Scripts"/* "$destination_dir/opt/share/pihole"
    cp --update=none "$core_path/advanced/Templates"/*.sh "$destination_dir/opt/share/pihole"
    cp --update=none "$core_path/advanced/Templates"/*.sql "$destination_dir/opt/share/pihole"
    cp --update=none "$core_path/advanced/Templates/pihole.cron" "$destination_dir/opt/etc/cron.d/pihole"
    cp --update=none "$core_path/advanced/Templates/logrotate" "$destination_dir/opt/etc/pihole"
    cp --update=none "$core_path/gravity.sh" "$destination_dir/opt/share/pihole/gravity.sh"
    cp --update=none "$core_path/automated install/basic-install.sh" "$destination_dir/opt/share/pihole/basic-install.sh"
    cp --update=none "$core_path/pihole" "$destination_dir/opt/bin/pihole"
fi

if [ ! -d "$destination_dir/opt/share/pihole/www/admin" ]; then
    echo "Copying web files..."
    mkdir -p "$destination_dir/opt/share/pihole/www/admin"
    cp -r --update=none "$web_path"/* "$destination_dir/opt/share/pihole/www/admin"
fi

if [ ! -f "$destination_dir/opt/bin/pihole-FTL" ]; then
    echo "Copying FTL binary..."
    cp --update=none "$ftl_path/pihole-FTL" "$destination_dir/opt/bin/pihole-FTL"
    file "$destination_dir/opt/bin/pihole-FTL"
fi

if [ ! -d "$destination_dir/CONTROL" ]; then
    echo "Copying files from 'files' directory..."
    cp -r --update=none "$root_path/files"/* "$destination_dir"
fi

if [ ! -f "$destination_dir/opt/etc/pihole/macvendor.db" ]; then
    if [ ! -f /tmp/pihole-macvendor.db ]; then
        echo "Downloading macvendor.db..."

        if ! curl -sSL "https://ftl.pi-hole.net/macvendor.db" -o "$destination_dir/opt/etc/pihole/macvendor.db"; then
            echo "Error: Could not download macvendor.db"
            exit 1
        fi

        cp -f "$destination_dir/opt/etc/pihole/macvendor.db" /tmp/pihole-macvendor.db || true
    else
        echo "Copying cached macvendor.db..."
        cp -f /tmp/pihole-macvendor.db "$destination_dir/opt/etc/pihole/macvendor.db"
    fi
fi

if [ ! -f "$destination_dir/opt/etc/pihole/versions" ]; then
    echo "Creating versions file..."

    for part in core web ftl; do
        part_path="${part}_path"

        if [ -d "${!part_path}" ] && [ -f "${!part_path}/.version" ]; then
            #shellcheck disable=SC1091
            . "${!part_path}/.version"

            part="${part^^}"
            {
                echo "${part}_VERSION=$VERSION"
                echo "${part}_BRANCH=$BRANCH"
                echo "${part}_HASH=$HASH"
            } >> "$destination_dir/opt/etc/pihole/versions"
        fi
    done
fi

echo "Setting permissions..."
find "$destination_dir" -type f -exec chmod 0644 {} \;
find "$destination_dir" -type d -exec chmod 0755 {} \;
chmod 755 "$destination_dir/opt/bin"/* "$destination_dir/opt/etc/init.d"/* 
chmod 600 "$destination_dir/opt/etc/cron.d/pihole"
find "$destination_dir/opt/share/pihole" -type f \( -name "*.sh" -o -name "COL_TABLE" \) -exec chmod 0755 {} \;
find "$destination_dir/opt/share/pihole/polyfill" -type f -exec chmod 0755 {} \;

echo "Created package files in $destination_dir"
