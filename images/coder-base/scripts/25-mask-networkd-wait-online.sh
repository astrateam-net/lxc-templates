#!/bin/sh
set -eux

# Bare debootstrap leaves systemd-networkd-wait-online.service enabled by preset,
# but this image uses ifupdown (networking.service owns eth0); systemd-networkd
# itself stays disabled. An enabled wait-online with no running networkd blocks
# network-online.target for its full 120s timeout on every boot, which delays
# coder-agent.service (After=network-online.target) by ~2 minutes. ifupdown's own
# ifupdown-wait-online.service already satisfies the target in ~1s. The stock
# debian-13-standard Proxmox template masks this unit; match that.
ln -sf /dev/null /etc/systemd/system/systemd-networkd-wait-online.service
