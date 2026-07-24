# coder-base — Proxmox CT gold image. Source template; render -> coder-base.yaml.

image:
  distribution: debian
  release: trixie
  architecture: amd64
  variant: default
  name: coder-base-debian-trixie-amd64
  description: |-
    Coder LXC workspace base ({{ image.distribution }} {{ image.release }})
  serial: "13.0.0" # base-major.minor.patch — major = base distro (13 = Debian 13)
  expiry: 30d

source:
  downloader: debootstrap
  same_as: sid # trixie debootstrap script may be absent on the runner; sid's works
  url: https://deb.debian.org/debian/
  keyserver: keyserver.ubuntu.com
  keys:
    - 0x126C0D24BD8A2942CC7DF8AC7638D0442B90D010
    - 0xA1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553
    - 0x6D33866EDD8FFA41C0143AEDDCC9EFBF77E11517
    - 0x80D15823B7FD1561F9F7BCDDDC30D7C23CBBABEE

targets:
  lxc:
    create_message: |-
      Coder workspace base ({{ image.description }}).
    config:
      - type: all
        before: 5
        content: |-
          lxc.include = LXC_TEMPLATE_CONFIG/debian.common.conf
      - type: user
        before: 5
        content: |-
          lxc.include = LXC_TEMPLATE_CONFIG/debian.userns.conf
      - type: all
        after: 4
        content: |-
          lxc.include = LXC_TEMPLATE_CONFIG/common.conf
      - type: user
        after: 4
        content: |-
          lxc.include = LXC_TEMPLATE_CONFIG/userns.conf
      - type: all
        content: |-
          lxc.arch = {{ image.architecture_personality }}

files:
  - path: /etc/hostname
    generator: hostname
  - path: /etc/hosts
    generator: hosts
  - path: /etc/mise/config.toml
    generator: dump
    content: |-
[[ file.Read "files/etc-mise-config.toml" | strings.TrimSpace | strings.Indent 6 ]]
  - path: /etc/profile.d/mise.sh
    generator: dump
    mode: "0755"
    content: |-
[[ file.Read "files/etc-profile.d-mise.sh" | strings.TrimSpace | strings.Indent 6 ]]

packages:
  manager: apt
  update: true
  cleanup: true
  sets:
    - packages:
        - ca-certificates
        - curl
        - sudo
        - git
        - jq
        - python3
        - openssh-client
        - locales
      action: install
    - packages:
        - build-essential
        - pkg-config
        - wget
        - gnupg
        - unzip
        - zip
        - xz-utils
        - rsync
        - file
        - tree
        - less
        - vim
        - htop
        - tmux
        - ripgrep
        - fd-find
        - man-db
        - bash-completion
      action: install
    - packages:
        - libssl-dev
        - zlib1g-dev
        - libbz2-dev
        - libreadline-dev
        - libsqlite3-dev
        - libffi-dev
        - liblzma-dev
      action: install
    - packages:
        - systemd-sysv
        - dbus
      action: install
    # t64 names required on Debian 13 (libgtk/libasound/libatk-bridge/libatspi).
    - packages:
        - xvfb
        - xauth
        - dbus-x11
        - libgtk-3-0t64
        - libnss3
        - libgbm1
        - libasound2t64
        - libatk-bridge2.0-0t64
        - libatspi2.0-0t64
        - libdrm2
        - libxcomposite1
        - libxdamage1
        - libxfixes3
        - libxkbcommon0
        - libxrandr2
        - libxss1
      action: install
      flags:
        - --no-install-recommends
  repositories:
    - name: sources.list
      url: |-
        deb https://deb.debian.org/debian {{ image.release }} main contrib non-free non-free-firmware
        deb https://deb.debian.org/debian {{ image.release }}-updates main contrib non-free non-free-firmware
        deb https://security.debian.org/debian-security {{ image.release }}-security main contrib non-free non-free-firmware

actions:
  - trigger: post-packages
    action: |-
[[ file.Read "scripts/20-user-locale.sh" | strings.TrimSpace | strings.Indent 6 ]]
  # post-files: /etc/mise/config.toml is written by then, so `mise install` reads node=24 from it
  - trigger: post-files
    action: |-
[[ file.Read "scripts/30-mise-node.sh" | strings.TrimSpace | strings.Indent 6 ]]

mappings:
  architecture_map: debian
