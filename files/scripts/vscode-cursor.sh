#!/usr/bin/env bash

set -oue pipefail

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

rpm --import https://downloads.cursor.com/keys/anysphere.asc
echo -e "[cursor]\nname=Cursor\nbaseurl=https://downloads.cursor.com/yumrepo\nenabled=1\ngpgcheck=1\ngpgkey=https://downloads.cursor.com/keys/anysphere.asc" > /etc/yum.repos.d/cursor.repo

dnf install -y code cursor
