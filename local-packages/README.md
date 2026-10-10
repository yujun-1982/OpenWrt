# OpenWrt x86_64 BIOS firmware

This repository builds an OpenWrt 25.12 x86_64 generic SquashFS image for legacy BIOS/GRUB with gzip-compressed images through GitHub Actions.

## Configuration

- Default OpenWrt ref: `openwrt-25.12` (selectable in Actions)
- Legacy BIOS/GRUB only; EFI image generation is disabled
- SquashFS, gzip, 256 MiB kernel partition, 1024 MiB rootfs partition
- LAN default: `10.10.10.2/24`
- Software flow offloading enabled; hardware flow offloading disabled
- LuCI Chinese, PassWall, TimeControl, Argon, WireGuard, diagnostics and requested base utilities
- SoftEther LuCI package is checked against the selected OpenWrt source revision

## Required custom APKs

The build expects these exact user-provided files under `local-packages/`:

- `luci-app-openclash-1.0.0-r1.apk`
- `ninjadesktop-lite-1.0.4-x86_64.apk`

They are custom packages and must not be replaced with public downloads. The build script attempts to add them to the staged root filesystem before the target image is assembled. The build must fail rather than silently treating a copied APK file as an installed package.

**Before uploading the APKs, change this repository to Private** if you do not intend to publish those binaries. Then open `local-packages/` in GitHub and use **Add file → Upload files** to upload both exact APKs. Keep the filenames unchanged.

## Run a build

1. Open **Actions**.
2. Select **Build OpenWrt x86_64 BIOS**.
3. Select **Run workflow**.
4. Keep `openwrt-25.12` unless you intentionally want another branch/tag.
5. Download the artifact from the completed run.

The workflow retains the build log, final config, package list, APK SHA-256 hashes and firmware files for 14 days.

## First boot

Connect a computer to the router's LAN side and assign it an address in `10.10.10.0/24`, such as `10.10.10.10/24`. Then open `http://10.10.10.2/`.

The project does not map physical WAN/LAN ports because that depends on the hardware. Confirm that the selected image is a combined x86_64 legacy-BIOS image before flashing, and back up the current router configuration first.

## Notes

A successful repository setup is not the same as a successful firmware build. The first GitHub Actions run must be reviewed for source availability, package compatibility, local APK dependencies and the final image type before flashing.
