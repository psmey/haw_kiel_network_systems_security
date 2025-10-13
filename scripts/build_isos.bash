#!/usr/bin/env bash
# https://linuxconfig.org/how-to-repackage-an-ubuntu-iso-image-for-autoinstall-using-yaml
# This script will rebuild the ubuntu ISO with the provided autoinstall.yml
# files in the autoinstall folder

set -e
shopt -s nullglob

REPO_DIR="/workspaces/haw_kiel_network_systems_security"
ISO_PATH="${REPO_DIR}/iso/ubuntu-24.04.3-live-server-amd64.iso"
MOUNTED_ISO_DIR="/tmp/autoinstall/mounted"
EXTRACTED_ISO_DIR="/tmp/autoinstall/extracted"
OUTPUT_DIR="${REPO_DIR}/output"

echo "ℹ️  Ensuring directories exist..."
echo "${MOUNTED_ISO_DIR}"
echo "${EXTRACTED_ISO_DIR}"
echo "${OUTPUT_DIR}"
mkdir -p "${MOUNTED_ISO_DIR}" "${EXTRACTED_ISO_DIR}" "${OUTPUT_DIR}"

echo "🔄️ Extract ISO ${ISO_PATH} to ${EXTRACTED_ISO_DIR}"
xorriso -osirrox on -indev "${ISO_PATH}" -extract / "${EXTRACTED_ISO_DIR}"

echo "ℹ️  Activate autoinstall for ISO with boot command"
sed -i 's|linux[[:space:]]*/casper/vmlinuz  ---|linux\t/casper/vmlinuz autoinstall ---|' ${EXTRACTED_ISO_DIR}/boot/grub/grub.cfg

for autoinstall_file in ${REPO_DIR}/autoinstall/*/autoinstall.yaml; do
    name=$(basename "$(dirname "$autoinstall_file")")
    echo "ℹ️  Processing iso for $name"

    echo "➡️  Adding autoinstall.yaml to extracted ISO ${EXTRACTED_ISO_DIR}"
    cp "${autoinstall_file}" "${EXTRACTED_ISO_DIR}"

    ISO_OUTPUT_PATH="${OUTPUT_DIR}/ubuntu-24.04.3-live-server-amd64-${name}.iso"
    echo "🔄️ Repackage ISO to ${ISO_OUTPUT_PATH}"
    xorriso -as mkisofs -r \
        -V "Ubuntu ${name} autoinstall image" \
        -o "${ISO_OUTPUT_PATH}" \
        -J -l -b boot/grub/i386-pc/eltorito.img \
        -c boot.catalog -no-emul-boot -boot-load-size 4 -boot-info-table \
        "${EXTRACTED_ISO_DIR}"

    echo "✅ Repackaged ISO for ${name}"
done

echo "✅ Done"
