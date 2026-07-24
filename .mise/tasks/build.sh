#!/usr/bin/env bash
#MISE description="Render + distrobuilder build-lxc an image (Linux, root)"
#USAGE arg "<image>" help="Image dir under images/ (e.g. coder-base)"
set -eo pipefail

# shellcheck disable=SC2154  # usage_image from #USAGE
img="${usage_image:?}"
command -v distrobuilder >/dev/null 2>&1 || {
  echo "install distrobuilder: sudo snap install distrobuilder --classic" >&2; exit 1;
}

mise run render "$img" >/dev/null
mkdir -p "dist/$img"
sudo "$(command -v distrobuilder)" build-lxc "images/$img/$img.yaml" "dist/$img" --compression zstd
