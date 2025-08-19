# Pi-hole for Entware

Run [Pi-hole](https://pi-hole.net) directly on your [Entware](https://github.com/Entware/Entware) supported device.  

> [!WARNING]
> **Releases here are unofficial and not supported by the Pi-hole developers.**

Supported Entware architectures: **aarch64-3.10, armv7-3.2, x64-3.2**

## Requirements

You will need around **50 MB** of free memory to run the daemon and **around 100 MB** more to be able to update the gravity database without running out of memory.  
Keep in mind that memory requirements increase as you add more blocklists.  
Swap file is **recommended**.

## Installation

- Install Entware - check [their wiki](https://github.com/Entware/Entware/wiki) for instructions

- Add this repository to your `opkg.conf` configuration:

```bash
src/gz pi-hole https://jacklul.github.io/entware-pi-hole/[architecture]
# replace [architecture] with one of the supported architectures
```

- Install the package: `opkg update && opkg install pi-hole`

> [!NOTE]
> For device or firmware specific setup instructions check the [wiki](https://github.com/jacklul/entware-pi-hole/wiki).

## Running

- Add `pihole` user to the system, preferably as a non-login one **(optional but recommended)**
  - This can be as simple as `useradd --system --no-create-home --shell /sbin/nologin pihole` but on most embedded devices this will not persist after reboot so you will have to do a research on your own

- Start `pihole-FTL` daemon: `/opt/etc/init.d/S65pihole-FTL start`

> [!IMPORTANT]
> The service might initially not start due to ports being in use - check the logs in `/opt/var/log/pihole` directory and make adjustments in `/opt/etc/pihole/pihole.toml` when necessary.  

## Support

Because how different each device can be I won't be able to help with every issue that can be device-specific but feel free to report them anyway.

## License

Contents of this repository are licensed under [MIT](/LICENSE).  
Pi-hole® is licensed under [EUPL](https://github.com/pi-hole/pi-hole?tab=License-1-ov-file).
