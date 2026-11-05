#!/usr/bin/env bash

set -oue pipefail

# The feed gives the current rpm URL; it changes with each release.
url=$(curl -fsSL https://api2.cursor.sh/updates/api/download/stable/linux-x64/sand | grep -o '"rpmUrl":"[^"]*"' | cut -d'"' -f4)
dnf install -y "$url"
