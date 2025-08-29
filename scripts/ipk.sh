#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>
# Based on https://github.com/Entware/Entware/blob/master/scripts/ipkg-build

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
readonly timestamp="$(date)"
package_dir="$1"
package_version="$2"
package_architecture="$3"
destination_dir="$4"

################

set -e

[ -z "$package_dir" ] && { echo "Error: Package directory not provided"; exit 1; }
[ ! -d "$package_dir" ] && { echo "Error: Directory $package_dir does not exist"; exit 1; }
[ -z "$package_version" ] && { echo "Error: Package version not provided"; exit 1; }
[ -z "$package_architecture" ] && { echo "Error: Package architecture not provided"; exit 1; }
[ -z "$destination_dir" ] && destination_dir="$(dirname "$script_dir")"
[ ! -d "$destination_dir" ] && { echo "Error: Directory $destination_dir does not exist"; exit 1; }

# If version string is a branch name then append a timestamp to it
if echo "$package_version" | grep -Eq '^\w+$'; then
    package_version="$package_version-$(date +%s)"
fi

if ! echo "$package_version" | grep -Eq '^[a-zA-Z0-9_.+-]+$'; then
    echo "Error: Package version contains illegal characters"
    exit 1
fi

package_dir="$(realpath "$package_dir")"
destination_dir="$(realpath "$destination_dir")"

[ ! -d "$package_dir/CONTROL" ] && { echo "Error: Directory $package_dir has no CONTROL subdirectory"; exit 1; }

for field in Package Version Architecture Installed-Size; do
    if ! grep -q "^$field" < "$package_dir/CONTROL/control"; then
        echo "Error: Missing '$field' field in control file"
        exit 1
    fi
done

#shellcheck disable=SC2164
cd "$package_dir"

# validate package name and set output package file
package_name="$(grep "^Package:" < "$package_dir/CONTROL/control" | sed -e "s/^[^:]*:[[:space:]]*//")"
package_file="$destination_dir/${package_name}_${package_version}_${package_architecture}.ipk"

if ! echo "$package_name" | grep -Eq '^[a-zA-Z0-9_-]+$'; then
    echo "Error: Package name contains illegal characters"
    exit 1
fi

# work in temporary dir
tmp_dir="/tmp/IPKG_BUILD.$$"
[ ! -w /tmp ] && tmp_dir="$(dirname "$script_dir")/tmp/IPKG_BUILD.$$"
mkdir -p "$tmp_dir"

installed_size=0
if [ -d "$package_dir/opt" ]; then
    # create data archive
    tar --exclude CONTROL --exclude '*.ipk' --format=gnu --numeric-owner --owner=0 --group=0 --sort=name -cpf - --mtime="$timestamp" . | gzip -n - > "$tmp_dir/data.tar.gz"
fi

# update/set variables in control file
installed_size=$(zcat < "$tmp_dir"/data.tar.gz | wc -c)
sed -e "s/^Version:.*/Version: $package_version/" -i "$package_dir/CONTROL/control"
sed -e "s/^Architecture:.*/Architecture: $package_architecture/" -i "$package_dir/CONTROL/control"
sed -e "s/^Installed-Size:.*/Installed-Size: $installed_size/" -i "$package_dir/CONTROL/control"

# if these pre/post scripts exist make sure they are executable
find "$package_dir/CONTROL" -type f \( -name "post*" -o -name "pre*" \) -exec chmod 0755 {} \;

# create control archive
( cd "$package_dir/CONTROL" && tar --format=gnu --numeric-owner --owner=0 --group=0 --sort=name -cf - --mtime="$timestamp" . | gzip -n - > "$tmp_dir/control.tar.gz" )

# package format version
echo "2.0" > "$tmp_dir/debian-binary"

# package everything into single ipk archive
archives="./debian-binary ./control.tar.gz"
[ -f "$tmp_dir/data.tar.gz" ] && archives="$archives ./data.tar.gz"
rm -f "$package_file"
#shellcheck disable=SC2086
( cd "$tmp_dir" && tar --format=gnu --numeric-owner --owner=0 --group=0 --sort=name -cf - --mtime="$timestamp" $archives | gzip -n - > "$package_file" )

# cleanup
rm -fr "$tmp_dir"

echo "Created IPK package $package_file"
