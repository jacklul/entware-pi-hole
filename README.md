# Pi-hole for Entware

Run [Pi-hole](https://pi-hole.net) directly on your [Entware](https://github.com/Entware/Entware) supported device.  

> [!IMPORTANT]
> **Releases here are unofficial and not supported by the Pi-hole developers.**

> [!WARNING]
> This project is a **proof-of-concept-alpha™** and was tested only on **Asus RT-AX58U v2** running official **388.2** firmware with **BusyBox v1.24.1**.

## Requirements

Only **aarch64-3.10, armv7-3.2 and x64-3.2** Entware architectures are supported.  
You will need at least **50-100 MB** of free memory on the device to be able to update the gravity database without running out of memory.  
Swap file is **recommended**.  

> [!NOTE]
> MIPS architecture is currently not supported by Pi-hole's builder images.  
> Architectures which are EOL by Entware team will not be supported.

## Installation

- Add this repository to your `opkg.conf` configuration:

```bash
src/gz pi-hole https://jacklul.github.io/entware-pi-hole/[architecture]
# replace [architecture] with one of the supported architectures
```

- Install the package: `opkg update && opkg install pi-hole`

- Start `pihole-FTL` daemon: `/opt/etc/init.d/S55pihole-FTL start`

> [!IMPORTANT]
> The service might initially not start due to ports being in use - make adjustements in `/opt/etc/pihole/pihole.toml` when necessary.  
> For device or firmware specific setup instructions check the [Wiki](https://github.com/jacklul/entware-pi-hole/wiki).

## Support

Because how different each device can be I won't be able to help with every issue that can be device-specific but feel free to report them anyway.

## License

Contents of this repository are licensed under [MIT](/LICENSE).  
Pi-hole® is licensed under [EUPL](https://github.com/pi-hole/pi-hole?tab=License-1-ov-file).
