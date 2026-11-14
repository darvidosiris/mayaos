# Building MayaOS

## Prerequisites

On a Debian/Ubuntu amd64 host (recommended: Debian 12+ or 13):

```bash
sudo apt-get update
sudo apt-get install -y \
  live-build debootstrap squashfs-tools xorriso \
  isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin \
  mtools dosfstools ca-certificates curl rsync
```

Rough space budget:

| Stage | Typical free space needed |
|-------|---------------------------|
| Bootstrap + chroot | 4–8 GiB |
| Squashfs + hybrid ISO | +4–8 GiB |
| Comfortable total | **≥ 15 GiB** free on the build volume |

Root (or passwordless sudo) is required for `lb build` (chroot, loop mounts, device nodes).

## Steps

```bash
./scripts/check-deps.sh          # verify tools
./scripts/check-chromebook.sh    # if on Crostini: disk/KVM warnings
sudo ./scripts/build-iso.sh      # configure + build
```

Successful builds copy the hybrid ISO (and checksums) into `out/`.

### Useful flags

```bash
sudo ./scripts/build-iso.sh --clean     # wipe build/ first
sudo ./scripts/build-iso.sh --config-only
sudo ./scripts/build-iso.sh --skip-deps-check
```

## live-build overview

`scripts/build-iso.sh`:

1. Resolves repo root and `VERSION`
2. Optionally runs dependency checks
3. Creates/refreshes `build/` and rsyncs `config/` into it
4. Runs `lb config` via `config/auto/config` (Debian **trixie**, amd64, hybrid ISO)
5. Runs `lb build`
6. Publishes `out/mayaos-<version>-amd64.hybrid.iso` + SHA256

Package lists:

- `config/package-lists/mayaos.list.chroot` — base OS utilities
- `config/package-lists/desktop.list.chroot` — XFCE stack + lightdm

## Debian 13 (trixie) notes

- Suite is `trixie`. Mirror defaults to `https://deb.debian.org/debian`.
- Building **trixie** from a **bookworm** host is supported by live-build/debootstrap when network access is available; use an up-to-date `debootstrap` if bootstrap fails on suite recognition.
- Security/updates components are enabled when the mirror provides them for trixie.

## What this does *not* do

- Does not download a vendor ZIP of MayaOS
- Does not mark the ISO “verified bootable” — run `./scripts/test-qemu.sh` after build
- Does not install MayaOS onto the Chromebook host disk

## Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `lb: command not found` | Install `live-build` |
| Bootstrap fails for trixie | Old debootstrap; upgrade or build on trixie |
| ENOSPC / no space | Expand disk; move `build/`/`out/` to larger volume (`MAYAOS_BUILD_DIR`) |
| Loop/mount errors in Crostini | Nested virt limits; prefer CI or a full Linux host |
| ISO missing after “success” | Check `build/` logs; ensure hybrid ISO name pattern |
