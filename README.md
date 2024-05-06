# Pi-hole via Entware

Run [Pi-hole](https://pi-hole.net) directly on your [Entware](https://github.com/Entware/Entware) supported device.  
**Releases here are unofficial and not supported by the Pi-hole developers.**

> [!WARNING]
> This project is a **proof-of-concept-alpha™** and was tested only on **Asus RT-AX58U v2** running official **388.2** firmware with **BusyBox v1.24.1**.

### Notable changes

There are some changes compared to the official releases:

- `ss` is replaced with `netstat` when not found (used in `pihole status`) - Entware has no `iproute2` package
- `pihole`'s `tricoder`, `debug`, `update`, `reconfigure`, `uninstall` and `checkout` functions are removed

## Installation

Add this repository to your `opkg.conf` configuration:

```bash
src/gz entware-pi-hole https://jacklul.github.io/entware-pi-hole/[architecture]
# replace [architecture] with one of the supported architectures
```

Then run `opkg update` and `opkg install pi-hole`

Run install tasks with `/opt/etc/init.d/S55pihole-FTL install` command

Start `pihole-FTL` by running `/opt/etc/init.d/S55pihole-FTL start`

> [!NOTE]
> Default configuration uses Google's DNS as upstream servers, runs HTTP(S) server on ports **5080/5443** and DNS resolver on **5053** (loopback interface only) - everything can be changed in `/opt/etc/pihole/pihole.toml`.

## Support

Because how different each device can be I won't be able to help with every issue that can be device-specific but feel free to report them anyway.

## Building

Everything here was designed to build through [Github Actions](https://github.com/features/actions) but it can also be done manually:

<details><summary>Show the instructions!</summary>

```bash
# Fetch repositories
./scripts/dev.sh development-v6

# Prepare pi-hole/pi-hole
./scripts/patch.sh core dev/core
./scripts/test.sh core dev/core
./scripts/version.sh dev/core

# Prepare pi-hole/web
./scripts/patch.sh web dev/web
./scripts/test.sh web dev/web
./scripts/version.sh dev/web

# Prepare pi-hole/FTL
./scripts/patch.sh FTL dev/FTL
./scripts/test.sh FTL dev/FTL
./scripts/version.sh dev/FTL

# Here you must compile FTL to dev/FTL/pihole-FTL
# For instructions check the official repository

# Build package files in ./build directory
mkdir ./build
./scripts/build.sh ./build

# then build the IPK package
# (you will need sudo access to set ownership of files to uid/gid 0)
./scripts/ipk.sh ./build

# the package will be saved at the root of this repository
```
</details>
