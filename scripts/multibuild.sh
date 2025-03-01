#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

package_dir="$1"
package_version="$2"
search_dir="$3"
output_dir="$4"

# This array maps Entware architectures to FTL binary architectures
declare -A architectures=(
    ["aarch64-3.10"]="arm64"
    #["armv5-3.2"]="armv5" # EOS by Entware team
    #["armv7-2.6"]="armv7" # EOS by Entware team
    ["armv7-3.2"]="armv7"
    #["mipsel-3.4"]="mipsel"
    #["mips-3.4"]="mips"
    ["x64-3.2"]="amd64"
    #["x86-2.6"]="386" # EOS by Entware team
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

binary_dir="$(find "$search_dir" -type d -name "binary" -print -quit)"
[ -z "$binary_dir" ] && binary_dir="$search_dir"

for key in "${!architectures[@]}"; do
    entware_architecture="${key}"
    binary_architecture="${architectures[$key]}"

    binary_file="$(find "$search_dir" -name "pihole-FTL-$binary_architecture" -print -quit)"
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
