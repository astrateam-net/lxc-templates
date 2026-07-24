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
from a YAML definition per image. Proxmox CT templates are **LXC-format** (the
same rootfs tarballs `pveam` ships), so we use `build-lxc` — not `build-incus`
(that's Incus/LXD squashfs format):

```bash
# one template -> rootfs.tar.zst + meta.tar.zst
distrobuilder build-lxc images/<name>/<name>.yaml dist/<name>/ --compression zstd
# dist/<name>/rootfs.tar.zst is the Proxmox CT template:
#   scp -> /var/lib/vz/template/cache/  (or any CT template storage)
#   pct create <vmid> local:vztmpl/<name>.tar.zst ...
```

A definition YAML has: `image` (distro/release/arch), `source` (downloader —
`debootstrap`, `alpine-http`, …), `targets.lxc.config`, `files` (generators:
`hostname`, `hosts`, `dump`, `remove`, …), `packages` (our core set here) and
`actions` (bootstrap glue by trigger: `post-unpack` → `post-packages`). Full
reference: `.upstream/distrobuilder/doc/reference/`.

## Layout

```
images/<name>/<name>.yaml   distrobuilder definition (base image, packages, files, actions)
dist/                       built rootfs tarballs (gitignored)
.github/                    CI: detect changed templates -> build -> release per template
```

The per-image dir is named after the template (`images/<name>/<name>.yaml`), the
same way `appimages` keys off `apps/<app>/`. Structure fills in as the first real
template lands — no empty scaffolding.

## CI

Thin `release.yaml` / `pull-request.yaml` orchestrators detect changed templates
(dirs under `images/`) and fan out to the reusable `template-builder.yaml`, which
installs `distrobuilder` (snap), runs `build-lxc`, and — on `main` only —
publishes the CT template as a GitHub Release tagged `<name>-<version>`. Mirrors
the `appimages` CI shape; the build engine is distrobuilder, not `docker bake`.

## Conventions

- **`image.serial` is the gold-image version.** Every definition must set it (a
  semver like `1.0.0` or a date like `2026.07.24`); it becomes the release tag
  and the CT template's serial. CI fails loudly if it's missing.
- Pin to explicit upstream base versions; don't float on `latest`.
