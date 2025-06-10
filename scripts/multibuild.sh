#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

package_dir="$1"
package_version="$2"
search_dir="$3"
output_dir="$4"

# This array maps Entware architectures to FTL binary architectures
declare -A architectures=(
    ["aarch64-3.10"]="arm64"
    #["armv5-3.2"]="armv5" # EOS by Entware team / Not supported by Pi-hole
    #["armv7-2.6"]="armv7" # EOS by Entware team
    ["armv7-3.2"]="armv7"
    #["mipsel-3.4"]="mipsel" # Not supported by Pi-hole
    #["mips-3.4"]="mips" # Not supported by Pi-hole
    ["x64-3.2"]="amd64"
    #["x86-2.6"]="386" # EOS by Entware team
    #["cortex-a15-3x"]="armv7" # Voxel's firmware Entware
)

# This array maps Entware architectures to target directory names
declare -A directories=(
    ["aarch64-3.10"]="aarch64-k3.10"
    ["armv5-3.2"]="armv5sf-k3.2"
    ["armv7-2.6"]="armv7sf-k2.6"
    ["armv7-3.2"]="armv7sf-k3.2"
    ["mipsel-3.4"]="mipselsf-k3.4"
    ["mips-3.4"]="mipssf-k3.4"
    ["x64-3.2"]="x64-k3.2"
    ["x86-2.6"]="x86-k2.6"
)

################

set -e

[ -z "$GITHUB_WORKSPACE" ] && { echo "This script must run inside Github Actions"; exit 1; }
[ -z "$package_dir" ] && { echo "Error: Package directory not provided"; exit 1; }
[ -z "$package_version" ] && { echo "Error: Package version not provided"; exit 1; }
[ -z "$search_dir" ] && { echo "Error: Search directory not provided"; exit 1; }
[ -z "$output_dir" ] && { echo "Error: Output directory not provided"; exit 1; }

# Find the folder containing artifacts with FTL binaries
binary_file="$(find "$search_dir" -type f -name "pihole-FTL-*" -print -quit)"
binary_dir="$search_dir/ftl"

if [ -n "$binary_file" ]; then
    binary_dir_tmp="$(dirname "$binary_file")"

    while [ "$binary_dir_tmp" != "/" ] && [ "$binary_dir_tmp" != "." ]; do
        binary_dir_tmp="$(dirname "$binary_dir_tmp")"

        if [ -d "$search_dir/$(basename "$binary_dir_tmp")" ]; then
            binary_dir=$binary_dir_tmp
            break
        fi
    done
fi

for key in "${!architectures[@]}"; do
    entware_architecture="${key}"
    binary_architecture="${architectures[$key]}"

    binary_file="$(find "$search_dir" -type f -name "pihole-FTL-$binary_architecture" -print -quit)"
    if [ -z "$binary_file" ]; then
        echo "Skipping $entware_architecture as binary (pihole-FTL-$binary_architecture) was not found"
        continue
    fi
    binary_version_file="$(dirname "$binary_file")/.version"

    target_dir="$entware_architecture"
    [ -n "${directories[$key]}" ] && target_dir="${directories[$key]}"

    # Cleanup after previous build
    #shellcheck disable=SC2115
    #rm -fr "$package_dir"/* # This is currently not necessary
    rm -f "$package_dir/bin/pihole-FTL" "$package_dir/opt/etc/pihole/versions"

    echo "Building for $entware_architecture..."

    cp -f "$binary_file" "$binary_dir/pihole-FTL"
    cp -f "$binary_version_file" "$binary_dir/.version"

    mkdir -p "$output_dir/$target_dir"

    bash ./scripts/build.sh "$package_dir" "$search_dir"
    bash ./scripts/ipk.sh "$package_dir" "$package_version" "$entware_architecture" "$output_dir/$target_dir"
done
