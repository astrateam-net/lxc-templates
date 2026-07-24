# lxc-templates

Proxmox **CT template** (LXC gold-image) factory. Sibling to
[`containers`](https://github.com/astrateam-net/containers) (Docker images) and
[`appimages`](https://github.com/astrateam-net/appimages) (`.AppImage`s): a
declarative-definition-in, built-artifact-out factory.

Each template under `images/` builds a pristine upstream base + our core package
set into a Proxmox LXC rootfs (`rootfs.tar.zst` + `pct` config), published as a
release asset. The artifact is a **gold CT template** you drop into Proxmox
template storage and clone from.

## Why

Proxmox has no cloud-init for LXC. A Coder workspace backed by a Proxmox LXC can
otherwise only be shaped at runtime by the `coder_agent` startup script — slow,
re-run on every rebuild, and fragile. Baking core packages into the CT template
moves that work from per-workspace runtime to build-time: workspaces boot ready,
and the agent startup shrinks to workspace-specific glue.

## Build (planned)

Templates are built with [`distrobuilder`](https://github.com/lxc/distrobuilder)
from a YAML definition per image:

```bash
# one template
distrobuilder build-incus images/<name>/<name>.yaml --type=split   # -> rootfs + metadata
# package into a Proxmox CT template tarball -> dist/<name>.tar.zst
```

## Layout (planned)

```
images/<name>/<name>.yaml   distrobuilder definition (base image, packages, files, actions)
dist/                       built rootfs tarballs (gitignored)
```

Structure lands as the first real template does — no empty scaffolding.

## Conventions

- **Public package installs only.** No secrets in template definitions; anything
  workspace-specific and sensitive stays in the Coder template / 1Password, not baked in.
- Pin to explicit upstream base versions; don't float on `latest`.
