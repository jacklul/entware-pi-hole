#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

PACKAGE_DIR="$1"
PACKAGE_VERSION="$2"
SEARCH_DIR="$3"
OUTPUT_DIR="$4"

# This array maps Entware architectures to FTL binary architectures
declare -A ARCHITECTURES=(
    ["aarch64-3.10"]="arm64"
    #["armv5-3.2"]="armv5" # EOS by Entware team
    #["armv7-2.6"]="armv7" # EOS by Entware team
    ["armv7-3.2"]="armv7"
    ["mipsel-3.4"]="mipsel"
    ["mips-3.4"]="mips"
    ["x64-3.2"]="amd64"
    #["x86-2.6"]="386" # EOS by Entware team
    ["generic"]="generic" # Package without FTL binary
)

# This array maps Entware architectures to target directory names
declare -A DIRECTORIES=(
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
    BINARY_VERSION_FILE="$(dirname "$BINARY_FILE")/.version"

    TARGET_DIR="$ENTWARE_ARCHITECTURE"
    [ -n "${DIRECTORIES[$KEY]}" ] && TARGET_DIR="${DIRECTORIES[$KEY]}"

    # Cleanup after previous build
    #shellcheck disable=SC2115
    #rm -fr "$PACKAGE_DIR"/* # This is currently not necessary
    rm -f "$PACKAGE_DIR/bin/pihole-FTL" "$PACKAGE_DIR/opt/etc/pihole/versions"

    echo "Building for $ENTWARE_ARCHITECTURE..."

    cp -f "$BINARY_FILE" "$BINARY_DIR/pihole-FTL"
    cp -f "$BINARY_VERSION_FILE" "$BINARY_DIR/.version"

    mkdir -p "$OUTPUT_DIR/$TARGET_DIR"

    bash ./scripts/build.sh "$PACKAGE_DIR" "$SEARCH_DIR"
    [ "$ENTWARE_ARCHITECTURE" = "generic" ] && rm -f "$PACKAGE_DIR/opt/bin/pihole-FTL"
    bash ./scripts/ipk.sh "$PACKAGE_DIR" "$PACKAGE_VERSION" "$ENTWARE_ARCHITECTURE" "$OUTPUT_DIR/$TARGET_DIR"
done
