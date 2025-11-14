#!/usr/bin/env bash
# Export build ISOs to Virtual Box dir, this mainly exists because
# Windows can't really access WSL dirs and so you can just youse your designated
# vbox ISO folder
# Note: This also only works inside the WSL not the devcontainer!

cp -v ./output/* /mnt/c/Users/psmey/VirtualBox\ VMs/ISOs/

echo "✅ Done!"
