# Pi-hole for Entware

Run [Pi-hole](https://pi-hole.net)® directly on your [Entware](https://github.com/Entware/Entware) supported device.  
**Releases here are unofficial and not supported by the Pi-hole developers.**

> [!WARNING]
> This project is a **proof-of-concept-alpha™** and was tested only on **Asus RT-AX58U v2** running official **388.2** firmware with **BusyBox v1.24.1**.

## Installation

- Add this repository to your `opkg.conf` configuration:

```conf
src/gz pi-hole https://jacklul.github.io/entware-pi-hole/[architecture]
# replace [architecture] with one of the supported architectures
```

- Install the package:

```bash
opkg update
opkg install pi-hole
```

- Start `pihole-FTL` daemon:

```bash
/opt/etc/init.d/S55pihole-FTL start
```

> [!NOTE]
> Default configuration uses Google's DNS as upstream servers, runs HTTP(S) server on ports **5080/5443** and DNS resolver on **5053** (loopback interface only) - everything can be changed in `/opt/etc/pihole/pihole.toml`.
> The default ports and interface were set specifically to not initially conflict with anything that could be running in the system already.

## Support

Because how different each device can be I won't be able to help with every issue that can be device-specific but feel free to report them anyway.

## Building

Everything here was designed to build through [Github Actions](https://github.com/features/actions) but it can also be done manually:

<details>
<summary>Show the instructions</summary>

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
./scripts/ipk.sh ./build dev armv7-3.2

# the package will be saved at the root of this repository
```
</details>

## License

Contents of this repository are licensed under [MIT](/LICENSE).  
Pi-hole® is licensed under [EUPL](https://github.com/pi-hole/pi-hole?tab=License-1-ov-file).
