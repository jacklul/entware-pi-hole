#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

PACKAGE_DIR="$1"
PACKAGE_VERSION="$2"
SEARCH_DIR="$3"
OUTPUT_DIR="$4"

# This array maps Entware architectures to FTL binary architectures
declare -A ARCHITECTURES=(
    ["aarch64-3.10"]="aarch64"
    #["armv5-3.2"]="armv5" # EOS by Entware team
    #["armv7-2.6"]="armv7" # EOS by Entware team
    ["armv7-3.2"]="armv7"
    ["mipselsf-3.4"]="mipsel"
    ["mipssf-3.4"]="mips"
    ["x64-3.2"]="amd64"
    #["x86-2.6"]="i386" # EOS by Entware team
)

################

set -e

[ -z "$GITHUB_WORKSPACE" ] && { echo "This script must run inside Github Actions"; exit 1; }
[ "$UID" -ne 0 ] && { echo "This script must run as root"; exit 1; }
[ -z "$PACKAGE_DIR" ] && { echo "Error: Package directory not provided"; exit 1; }
[ -z "$PACKAGE_VERSION" ] && { echo "Error: Package version not provided"; exit 1; }
[ -z "$SEARCH_DIR" ] && { echo "Error: Search directory not provided"; exit 1; }
[ -z "$OUTPUT_DIR" ] && { echo "Error: Output directory not provided"; exit 1; }

BINARY_DIR="$(find "$SEARCH_DIR" -type d -name "binary" -print -quit)"
[ -z "$BINARY_DIR" ] && BINARY_DIR="$SEARCH_DIR"

for KEY in "${!ARCHITECTURES[@]}"; do
    ENTWARE_ARCHITECTURE="${KEY}"
    BINARY_ARCHITECTURE="${ARCHITECTURES[$KEY]}"

    BINARY_FILE="$(find "$SEARCH_DIR" -name "pihole-FTL-$BINARY_ARCHITECTURE" -print -quit)"
    if [ -z "$BINARY_FILE" ]; then
        echo "Skipping $ENTWARE_ARCHITECTURE as binary (pihole-FTL-$BINARY_ARCHITECTURE) was not found"
        continue
    fi

    #shellcheck disable=SC2115
    #rm -fr "$PACKAGE_DIR"/*

    echo "Building IPK package for $ENTWARE_ARCHITECTURE..."

    rm -f "$PACKAGE_DIR/opt/etc/pihole/versions"
    cp -f "$BINARY_FILE" "$BINARY_DIR/pihole-FTL"
    cp -f "$(dirname "$BINARY_FILE")/.version" "$BINARY_DIR/.version"

    mkdir -p "$OUTPUT_DIR/$ENTWARE_ARCHITECTURE"

    bash ./scripts/build.sh "$PACKAGE_DIR" "$SEARCH_DIR"
    bash ./scripts/ipk.sh "$PACKAGE_DIR" "$PACKAGE_VERSION" "$ENTWARE_ARCHITECTURE" "$OUTPUT_DIR/$ENTWARE_ARCHITECTURE"
done
