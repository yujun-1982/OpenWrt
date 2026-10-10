#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/openwrt"
ARTIFACT_DIR="${ROOT_DIR}/artifacts"
OPENWRT_REF="${OPENWRT_REF:-openwrt-25.12}"
JOBS="${JOBS:-2}"
APK_DIR="${ROOT_DIR}/local-packages"
mkdir -p "${ARTIFACT_DIR}"
exec > >(tee -a "${ARTIFACT_DIR}/build.log") 2>&1
die(){ echo "ERROR: $*" >&2; exit 1; }
for f in configs/x86_64.config files/etc/uci-defaults/99-custom-settings local-packages/luci-app-openclash-1.0.0-r1.apk local-packages/ninjadesktop-lite-1.0.4-x86_64.apk; do
  [[ -f "${ROOT_DIR}/$f" ]] || die "Required file missing: $f"
done
(cd "${APK_DIR}" && sha256sum *.apk) | tee "${ARTIFACT_DIR}/local-apk-sha256.txt"
if [[ ! -d "${SOURCE_DIR}/.git" ]]; then
  git clone --depth=1 --branch "${OPENWRT_REF}" https://github.com/openwrt/openwrt.git "${SOURCE_DIR}"
else
  git -C "${SOURCE_DIR}" fetch --depth=1 origin "${OPENWRT_REF}"
  git -C "${SOURCE_DIR}" checkout -B build-target FETCH_HEAD
fi
cd "${SOURCE_DIR}"
grep -qE '^[[:space:]]*src-git[[:space:]]+passwall_packages[[:space:]]' feeds.conf.default || echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >> feeds.conf.default
clone_app(){ local url="$1" dest="$2"; git clone --depth=1 "$url" "$dest"; }
mkdir -p package/third-party
clone_app https://github.com/xiaorouji/luci-app-passwall.git package/third-party/luci-app-passwall
clone_app https://github.com/sirpdboy/luci-app-timecontrol.git package/third-party/luci-app-timecontrol
clone_app https://github.com/jerrykuku/luci-theme-argon.git package/third-party/luci-theme-argon
./scripts/feeds update -a
./scripts/feeds install -a
[[ -d luci/applications/luci-app-softether ]] || die "SoftEther LuCI source path not found on selected OpenWrt ref."
grep -Rqs 'define Package/luci-app-softether' luci/applications/luci-app-softether || die "SoftEther package definition not found."
cp "${ROOT_DIR}/configs/x86_64.config" .config
make defconfig
install -m 0755 "${ROOT_DIR}/files/etc/uci-defaults/99-custom-settings" files/etc/uci-defaults/99-custom-settings
make -j"${JOBS}" tools/install toolchain/install target/compile package/compile
make package/install
ROOTFS="$(find build_dir -maxdepth 3 -type d \( -name root-x86 -o -name root-x86_64 \) -print -quit)"
[[ -n "${ROOTFS}" ]] || die "Staged rootfs not found after package/install."
APK_TOOL="${SOURCE_DIR}/staging_dir/host/bin/apk"
[[ -x "${APK_TOOL}" ]] || die "Host apk tool not found."
"${APK_TOOL}" --root "${ROOTFS}" add --allow-untrusted --no-network "${APK_DIR}/luci-app-openclash-1.0.0-r1.apk" "${APK_DIR}/ninjadesktop-lite-1.0.4-x86_64.apk"
"${APK_TOOL}" --root "${ROOTFS}" info | tee "${ARTIFACT_DIR}/installed-packages.txt"
grep -Eiq openclash "${ARTIFACT_DIR}/installed-packages.txt" || die "OpenClash package missing from APK database."
grep -Eiq ninjadesktop "${ARTIFACT_DIR}/installed-packages.txt" || die "NinjaDesktop package missing from APK database."
make target/install
TARGET_DIR=bin/targets/x86/64
BIOS_IMAGE="$(find "${TARGET_DIR}" -maxdepth 1 -type f \( -name '*squashfs-combined.img.gz' -o -name '*squashfs-combined.img' \) -print -quit)"
[[ -n "${BIOS_IMAGE}" ]] || die "Combined SquashFS BIOS image not found."
! grep -qx 'CONFIG_GRUB_EFI_IMAGES=y' .config || die "UEFI image option is enabled."
cp .config "${ARTIFACT_DIR}/final.config"
printf 'OpenWrt ref: %s\nCommit: %s\nImage: %s\nSHA256: %s\n' "${OPENWRT_REF}" "$(git rev-parse HEAD)" "$(basename "${BIOS_IMAGE}")" "$(sha256sum "${BIOS_IMAGE}" | awk '{print $1}')" > "${ARTIFACT_DIR}/build-info.txt"
