#!/bin/bash
# Made by Jack'lul <jacklul.github.io>
# Based on https://github.com/Entware/Entware/blob/master/scripts/ipkg-build

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly TIMESTAMP="$(date)"
PACKAGE_DIR="$1"
PACKAGE_VERSION=$2
PACKAGE_ARCHITECTURE=$3
DESTINATION_DIR="$4"

################

set -e

if [ -z "$PACKAGE_DIR" ]; then
    echo "Error: Package directory not provided"
    exit 1
fi

if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Error: Directory $PACKAGE_DIR does not exist"
    exit 1
fi

if [ -z "$PACKAGE_VERSION" ]; then
    echo "Error: Package version not provided"
    exit 1
fi

if [ -z "$PACKAGE_ARCHITECTURE" ]; then
    echo "Error: Package architecture not provided"
    exit 1
fi

if [ -z "$DESTINATION_DIR" ]; then
    DESTINATION_DIR="$(dirname "$SCRIPT_DIR")"
else
    if [ ! -d "$DESTINATION_DIR" ]; then
        mkdir -pv "$DESTINATION_DIR"
    fi
fi

# If version string is a branch name then append a timestamp to it
if echo "$PACKAGE_VERSION" | grep -Eq '^\w+$'; then
    PACKAGE_VERSION="$PACKAGE_VERSION-$(date +%s)"
fi

if ! echo "$PACKAGE_VERSION" | grep -Eq '^[a-zA-Z0-9_.+-]+$'; then
    echo "Error: Package version contains illegal characters"
    exit 1
fi

PACKAGE_DIR="$(realpath "$PACKAGE_DIR")"
DESTINATION_DIR="$(realpath "$DESTINATION_DIR")"

if [ ! -d "$PACKAGE_DIR/CONTROL" ]; then
    echo "Error: Directory $PACKAGE_DIR has no CONTROL subdirectory"
    exit 1
fi

for FIELD in Package Version Architecture Installed-Size; do
    if ! grep -q "^$FIELD" < "$PACKAGE_DIR/CONTROL/control"; then
        echo "Error: Missing '$FIELD' field in control file"
        exit 1
    fi
done

#shellcheck disable=SC2164
cd "$PACKAGE_DIR"

# validate package name and set output package file
PACKAGE_NAME="$(grep "^Package:" < "$PACKAGE_DIR/CONTROL/control" | sed -e "s/^[^:]*:[[:space:]]*//")"
PACKAGE_FILE="$DESTINATION_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}_${PACKAGE_ARCHITECTURE}.ipk"

if ! echo "$PACKAGE_NAME" | grep -Eq '^[a-zA-Z0-9_-]+$'; then
    echo "Error: Package name contains illegal characters"
    exit 1
fi

# work in temporary dir
TMP_DIR="$DESTINATION_DIR/IPKG_BUILD.$$"
mkdir -vp "$TMP_DIR"

# create data archive
sudo chown -R 0:0 "$PACKAGE_DIR/opt"
tar --exclude CONTROL --format=gnu --numeric-owner --sort=name -cpf - --mtime="$TIMESTAMP" . | gzip -n - > "$TMP_DIR/data.tar.gz"

# update/set variables in control file
INSTALLED_SIZE=$(zcat < "$TMP_DIR"/data.tar.gz | wc -c)
sed -e "s/^Version:.*/Version: $PACKAGE_VERSION/" -i "$PACKAGE_DIR/CONTROL/control"
sed -e "s/^Architecture:.*/Architecture: $PACKAGE_ARCHITECTURE/" -i "$PACKAGE_DIR/CONTROL/control"
sed -e "s/^Installed-Size:.*/Installed-Size: $INSTALLED_SIZE/" -i "$PACKAGE_DIR/CONTROL/control"

# if these scripts exist make sure they are executable
[ -f "$PACKAGE_DIR/CONTROL/preinst" ] && chmod 0755 "$PACKAGE_DIR/CONTROL/preinst"
[ -f "$PACKAGE_DIR/CONTROL/postinst" ] && chmod 0755 "$PACKAGE_DIR/CONTROL/postinst"
[ -f "$PACKAGE_DIR/CONTROL/prerm" ] && chmod 0755 "$PACKAGE_DIR/CONTROL/prerm"
[ -f "$PACKAGE_DIR/CONTROL/postrm" ] && chmod 0755 "$PACKAGE_DIR/CONTROL/postrm"

# create control archive
sudo chown -R 0:0 "$PACKAGE_DIR/CONTROL"
( cd "$PACKAGE_DIR/CONTROL" && tar --format=gnu --numeric-owner --sort=name -cf - --mtime="$TIMESTAMP" . | gzip -n - > "$TMP_DIR/control.tar.gz" )

# package format version
echo "2.0" > "$TMP_DIR/debian-binary"

# package everything into single ipk archive
rm -f "$PACKAGE_FILE"
sudo chown 0:0 "$TMP_DIR/"*
( cd "$TMP_DIR" && tar --format=gnu --numeric-owner --sort=name -cf - --mtime="$TIMESTAMP" ./debian-binary ./data.tar.gz ./control.tar.gz | gzip -n - > "$PACKAGE_FILE" )

# cleanup
rm -fr "$TMP_DIR"

echo "Packaged $PACKAGE_DIR into $PACKAGE_FILE"
