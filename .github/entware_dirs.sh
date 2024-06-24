#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

TARGET_DIR="$1"

# This maps old directory name to new directory name
declare -A ENTWARE_DIRS=(
    ["aarch64-3.10"]="aarch64-k3.10"
    ["armv5-3.2"]="armv5sf-k3.2"
    ["armv7-2.6"]="armv7sf-k2.6"
    ["armv7-3.2"]="armv7sf-k3.2"
    ["mipsel-3.4"]="mipselsf-k3.4"
    ["mips-3.4"]="mipssf-k3.4"
    ["x64-3.2"]="x64-k3.2"
    ["x86-2.6"]="x86-k2.6"
)

for KEY in "${!ENTWARE_DIRS[@]}"; do
    ENTWARE_ARCHITECTURE="${KEY}"
    ENTWARE_DIR="${ENTWARE_DIRS[$KEY]}"

    if [ -d "$TARGET_DIR/$ENTWARE_ARCHITECTURE" ]; then
        mv -v "$TARGET_DIR/$ENTWARE_ARCHITECTURE" "$TARGET_DIR/$ENTWARE_DIR"
    fi
done
