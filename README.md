# OpenWrt x86_64 BIOS firmware

This repository is being prepared to build an OpenWrt 25.12 x86_64 generic firmware image for legacy BIOS/GRUB, with SquashFS and gzip, through GitHub Actions.

## Build status

The build workflow and configuration are being added. The two custom local APKs must remain the exact user-provided builds; they must be validated and integrated into the image build so they are installed at build time, not merely copied into the filesystem or installed on first boot.

## Important

Do not flash a firmware image until the GitHub Actions build completes successfully and the image is confirmed to be a legacy BIOS combined image. Back up the router first.
