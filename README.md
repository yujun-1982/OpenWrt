# OpenWrt x86_64 BIOS firmware

This repository is being configured to build OpenWrt 25.12 for x86_64 generic hardware using legacy BIOS/GRUB, SquashFS and gzip through GitHub Actions.

## Features requested

- Default OpenWrt ref: `openwrt-25.12`
- Legacy BIOS only; EFI image generation disabled
- Chinese LuCI, PassWall, TimeControl, Argon theme and WireGuard
- SoftEther LuCI app source/package validation
- LAN address `10.10.10.2/24`
- Software flow offloading enabled, hardware flow offloading disabled
- Requested base utilities and network diagnostics
- Custom OpenClash and NinjaDesktop APKs must be installed into the staged root filesystem during the build, not on first boot

## Required local APKs

Upload the exact files below into `local-packages/`:

- `luci-app-openclash-1.0.0-r1.apk`
- `ninjadesktop-lite-1.0.4-x86_64.apk`

Do not replace these custom packages with public downloads. **The repository is currently public; change it to Private before uploading the custom APKs** if you do not intend to publish them. In GitHub, open `local-packages/` → **Add file** → **Upload files** and upload both binaries with their filenames unchanged.

## Build

1. Open **Actions**.
2. Select **Build OpenWrt x86_64 BIOS**.
3. Click **Run workflow** and keep `openwrt-25.12` unless you intentionally want another ref.
4. After the run finishes, download its artifact and review the logs before flashing.

The workflow is manual-only for now so it will not start before the required local APK files are uploaded. Artifacts include build logs, the final config, package list, hashes and firmware output.

## First boot

Set a computer on the router LAN to an address in `10.10.10.0/24`, for example `10.10.10.10/24`, then open `http://10.10.10.2/`. Physical port mapping depends on the router hardware and is not assumed by this project.

A repository commit does not mean the firmware has built successfully. Verify the first Actions run, check the image is a combined x86_64 legacy-BIOS image, and back up the router before flashing.
