#!/usr/bin/env bash

[ "$(id -u)" -ne 0 ] && { echo "Admin privileges required!"; exit 1; }
! command -v git >/dev/null 2>&1 && { echo "Command 'git' not found!"; exit 1; }

echo "This script will install and patch PADD."
read -rp "Press Enter to continue..."

set -e
cd /opt/share/pihole
wget -O padd.sh https://install.padd.sh
chmod +x padd.sh
git apply --include=padd.sh padd.patch
echo "PADD has been installed. Run 'padd.sh' to start PADD."
