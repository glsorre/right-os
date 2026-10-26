enroll-secure-boot-key:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo mokutil --import /usr/share/right-os/secureboot/MOK.der
    echo "Reboot and choose 'Enroll MOK' in the blue MokManager screen, then enter the password you just set."
