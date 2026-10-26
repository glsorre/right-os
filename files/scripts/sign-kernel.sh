#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Sign the CachyOS kernel with the right-os MOK so it boots with Secure Boot enabled.

KEY=/tmp/certs/MOK.priv
CERT=/usr/share/right-os/secureboot/MOK.pem

if [[ ! -s "$KEY" ]]; then
    echo "Kernel signing key not found at $KEY" >&2
    exit 1
fi

# sbsigntools may already ship in the base image; only remove it if we installed it.
installed_sbsigntools=false
if ! rpm -q sbsigntools &>/dev/null; then
    dnf install -y sbsigntools
    installed_sbsigntools=true
fi

shopt -s nullglob
kernels=(/usr/lib/modules/*cachy*/vmlinuz)
if [[ ${#kernels[@]} -eq 0 ]]; then
    echo "No CachyOS kernel found in /usr/lib/modules" >&2
    exit 1
fi

for v in "${kernels[@]}"; do
    sbsign --key "$KEY" --cert "$CERT" --output "$v.signed" "$v"
    mv "$v.signed" "$v"
    sbverify --cert "$CERT" "$v"
done

if [[ "$installed_sbsigntools" == true ]]; then
    dnf remove -y sbsigntools
fi
