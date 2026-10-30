#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Build the TUXEDO keyboard modules for the CachyOS kernel and sign them with the right-os MOK.
# tuxedo-compat.patch skips the TUXEDO vendor check, since this Clevo reports "Notebook".

REPO=https://gitlab.com/tuxedocomputers/development/packages/tuxedo-drivers.git
TAG=v4.25.0
KEY=/tmp/certs/MOK.priv
CERT=/usr/share/right-os/secureboot/MOK.pem
PATCH="$(dirname "${BASH_SOURCE[0]}")/tuxedo-compat.patch"
# Only the Clevo/Uniwill keyboard stack; the rest is for other TUXEDO models.
MODULES=(tuxedo_keyboard tuxedo_compatibility_check clevo_acpi clevo_wmi uniwill_wmi tuxedo_io)

if [[ ! -s "$KEY" ]]; then
    echo "Kernel signing key not found at $KEY" >&2
    exit 1
fi

# Only remove the build deps we installed ourselves.
deps=()
for p in gcc make kernel-cachyos-devel-matched; do
    rpm -q "$p" &>/dev/null || deps+=("$p")
done
if [[ ${#deps[@]} -gt 0 ]]; then
    dnf install -y "${deps[@]}"
fi

src=$(mktemp -d)
git clone --depth 1 -b "$TAG" "$REPO" "$src"
git -C "$src" apply "$PATCH"

shopt -s nullglob
kernels=(/usr/lib/modules/*cachy*)
if [[ ${#kernels[@]} -eq 0 ]]; then
    echo "No CachyOS kernel found in /usr/lib/modules" >&2
    exit 1
fi

for dir in "${kernels[@]}"; do
    kver=$(basename "$dir")
    kdir=/usr/src/kernels/$kver
    hash=$(sed -n 's/^CONFIG_MODULE_SIG_HASH="\(.*\)"/\1/p' "$dir/config")
    make -C "$kdir" M="$src/src" clean
    make -C "$kdir" M="$src/src" modules
    dest=$dir/extra/tuxedo-drivers
    mkdir -p "$dest"
    for m in "${MODULES[@]}"; do
        ko=$(find "$src/src" -name "$m.ko")
        [[ -n "$ko" ]] || { echo "$m.ko was not built" >&2; exit 1; }
        "$kdir/scripts/sign-file" "$hash" "$KEY" "$CERT" "$ko"
        install -m 0644 "$ko" "$dest/"
        [[ -n "$(modinfo -F signer "$dest/$m.ko")" ]] || { echo "$m.ko is not signed" >&2; exit 1; }
    done
    depmod -a "$kver"
done

rm -rf "$src"
if [[ ${#deps[@]} -gt 0 ]]; then
    dnf remove -y "${deps[@]}"
fi
