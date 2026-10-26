rocm-setup:
    #!/usr/bin/env bash
    set -euo pipefail
    for g in render video; do
        getent group "$g" >/dev/null || grep "^$g:" /usr/lib/group | sudo tee -a /etc/group >/dev/null
        sudo usermod -aG "$g" "$USER"
    done
    echo "$USER is now in the render and video groups. Log out and back in for ROCm to see the GPU."
