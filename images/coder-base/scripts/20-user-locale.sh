#!/bin/sh
set -eux

sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# baked into the image = every clone shares this passwordless-sudo user (dev workspaces)
getent group sudo >/dev/null 2>&1 || groupadd --system sudo
id coder >/dev/null 2>&1 || useradd --create-home -s /bin/bash -u 1000 -G sudo coder
printf 'coder ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/coder
chmod 0440 /etc/sudoers.d/coder
