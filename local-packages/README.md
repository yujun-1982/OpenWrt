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

The build expects these user-provided files under `local-packages/`:

- `luci-app-openclash-1.0.0-r1.apk`
- `ninjadesktop-lite-1.0.4-x86_64.apk.part01`
- `ninjadesktop-lite-1.0.4-x86_64.apk.part02`

The NinjaDesktop APK is split only to fit GitHub's browser upload limit. The build script concatenates the two parts in order and verifies the original SHA-256 before using it. Do not replace these custom packages with public downloads or rename the files. The build script attempts to add the reconstructed APKs to the staged root filesystem before the target image is assembled; the build must fail if reconstruction or installation fails.

The repository is currently public, so these custom binaries are publicly accessible. To upload or replace the files, open `local-packages/` and use **Add file → Upload files**. Keep all filenames unchanged.

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
