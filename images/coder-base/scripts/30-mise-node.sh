#!/bin/sh
set -eux

# MISE_DATA_DIR routes BOTH installs and shims under a system path:
#   installs -> /usr/local/share/mise/installs  (also mise's default MISE_SYSTEM_INSTALLS_DIR)
#   shims    -> /usr/local/share/mise/shims      (MISE_SHIMS_DIR defaults to $MISE_DATA_DIR/shims)
# mise scans /usr/local/share/mise/installs unconditionally (env::shared_install_dirs),
# so tools resolve inside the systemd Coder agent with no MISE_DATA_DIR / no
# /etc/environment / no login shell. Keep this export — plain `mise install` needs
# it to land in the system path.
export MISE_DATA_DIR=/usr/local/share/mise
curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

# node version comes from /etc/mise/config.toml (system config, always loaded).
# `mise install` auto-reshims, so the shims exist before we symlink them.
mise install
ln -sf /usr/local/share/mise/shims/* /usr/local/bin/
