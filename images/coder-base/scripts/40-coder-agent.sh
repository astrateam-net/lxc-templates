#!/bin/sh
set -eux

# The injector only lands /opt/coder/init + init.env (per-workspace); the dir and
# the enabled unit are baked here.
install -d -m 0755 /opt/coder
install -d /etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/coder-agent.service \
  /etc/systemd/system/multi-user.target.wants/coder-agent.service
