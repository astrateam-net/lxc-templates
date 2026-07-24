# CLAUDE.md

Proxmox CT template (LXC gold-image) factory — sibling to `containers` (Docker
images) and `appimages` (`.AppImage`s). Each template under `images/` builds a
pristine upstream base + our core packages into a Proxmox LXC rootfs published as
a release asset. See [README.md](README.md) for the why and the build.

## Non-obvious facts

- **The artifact is a Proxmox CT template, not a running container.** Built with
  `distrobuilder` from a per-image YAML definition into a `rootfs.tar.zst` + `pct`
  config, dropped into Proxmox template storage and cloned from. No registry/push.
- **Gold images exist because Proxmox has no LXC cloud-init.** Baking core
  packages at build-time shrinks the Coder `coder_agent` startup to workspace glue.
- **Public package installs only.** No secrets in definitions; workspace-specific
  sensitive config stays in the Coder template / 1Password, never baked in.

## `.upstream/`

Gitignored reference clones — study upstream base-image / distrobuilder source
here to ground decisions; never a build input.
