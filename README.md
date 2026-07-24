# lxc-templates

Proxmox **CT template** (LXC gold-image) factory. Sibling to
[`containers`](https://github.com/astrateam-net/containers) (Docker images) and
[`appimages`](https://github.com/astrateam-net/appimages) (`.AppImage`s).

Each template builds a pristine upstream base + our packages into a Proxmox LXC
rootfs (`rootfs.tar.zst`), published as a GitHub Release asset — a **gold CT
template** you drop into Proxmox template storage and clone workspaces from.

## Why

Proxmox has no cloud-init for LXC. A Coder workspace on a Proxmox LXC can
otherwise only be shaped at runtime by the `coder_agent` startup script — slow,
re-run every rebuild. Baking packages into the CT template moves that to
build-time: workspaces boot ready.

## Generation contract

Definitions are **generated, not hand-written**. Each image is a gomplate
template plus validatable blocks; `mise run render` assembles them into the
committed definition distrobuilder builds:

```text
images/<name>/
  manifest.yaml.tpl   source template (gomplate, [[ ]] delimiters)
  scripts/*.sh        post-* action blocks (shellcheck)
  files/*             dropped-in config
  <name>.yaml         GENERATED, committed (distrobuilder definition)
```

Blocks inline at render time, so each lints on its own. Edit the template and
blocks — never `<name>.yaml`; CI fails if it drifts from a fresh render.

## Commands

```bash
mise run render <name>   # blocks -> images/<name>/<name>.yaml
mise run build  <name>   # render + distrobuilder build-lxc (Linux, root)
mise run check           # flint (shell/yaml/md/toml) + render-check
```

Output `dist/<name>/rootfs.tar.zst` is the Proxmox CT template: `scp` it to
`/var/lib/vz/template/cache/`, then `pct create`.

## CI

`pull-request.yaml` lints every PR and builds changed templates (no release).
`release.yaml` (on `main`) publishes each changed template as a GitHub Release
`<name>-<serial>`. Runs via `jdx/mise-action`; distrobuilder installed by snap.

## Toolchain (mise)

`gomplate` (render), `flint` + `shellcheck`/`ryl`/`rumdl`/`taplo` (lint), `hk`
(git hooks). `mise install` provisions all of it and installs the hooks.

## Conventions

- **`image.serial` = `<base-major>.<minor>.<patch>`** — major = base distro
  release (Debian 13 → `13`); bump minor/patch for changes on the same base,
  major on a rebase. Becomes the release tag `<name>-<serial>`.
- Pin explicit upstream base versions; don't float on `latest`.

## `.upstream/`

Gitignored reference clones (distrobuilder, lxc-ci) — study upstream here; never
a build input.
