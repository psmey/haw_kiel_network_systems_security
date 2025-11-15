#!/usr/bin/env bash
# Just move the PowerShell scripts to their respective share repos

SHARE_DIR="/mnt/c/Users/psmey/VirtualBox VMs/shared"

rm -rf "${SHARE_DIR:?}"/*

cp -r ./windows_lab/* "${SHARE_DIR}"

echo "✅ Done!"
