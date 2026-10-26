#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Rebuild the CachyOS kernel initramfs so it picks up /usr/lib/dracut/dracut.conf.d
# (amdgpu early KMS).

export DRACUT_NO_XATTR=1

shopt -s nullglob
kernels=(/usr/lib/modules/*cachy*)
if [[ ${#kernels[@]} -eq 0 ]]; then
    echo "No CachyOS kernel found in /usr/lib/modules" >&2
    exit 1
fi

for dir in "${kernels[@]}"; do
    kver=$(basename "$dir")
    dracut --no-hostonly --kver "$kver" --reproducible -v --add ostree -f "$dir/initramfs.img"
    chmod 0600 "$dir/initramfs.img"
    # Not grep -q: it exits early, SIGPIPEs lsinitrd and pipefail turns that into a failure
    lsinitrd "$dir/initramfs.img" | grep 'amdgpu.ko' || { echo "amdgpu missing from initramfs" >&2; exit 1; }
done
