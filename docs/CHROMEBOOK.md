# Chromebook Compatibility

MayaOS **targets** ordinary x86-64 PCs and VMs. Chromebooks running **Crostini** (Linux container, hostname often `penguin`) are useful as **development hosts**, with important limits.

## Detection

```bash
./scripts/check-chromebook.sh
```

Signals used (best-effort):

- Group membership `chronos-access`
- Presence of `/mnt/chromeos` or Cros milestone files
- Kernel/hostname heuristics (`penguin`)

## Typical Crostini constraints

| Area | Impact on MayaOS |
|------|------------------|
| Disk size | Default disks are small; ISO builds often need **≥ 15 GiB** free |
| Nested virtualization | `/dev/kvm` may exist; full live-build + QEMU GUI still constrained |
| Loop devices / mounts | `lb build` may fail on loop/squashfs mounts inside the container |
| RAM | 2–4 GiB common; QEMU desktops need careful sizing |
| Display | Headless QEMU (`-nographic` / VNC) preferred over SDL |

## Recommended workflow on Chromebook

1. Edit and validate locally: `./scripts/validate.sh`
2. Run Chromebook + deps checks
3. Prefer **GitHub Actions** (`.github/workflows/build-iso.yml`) for the actual ISO
4. Download the CI artifact to USB/external storage for hardware tests
5. Optional local QEMU: only after an ISO exists and KVM/disk checks pass

## Expanding Crostini disk

In ChromeOS: Settings → About Linux → resize disk. Leave headroom beyond the ISO size for chroot and squashfs.

## What is *not* supported here

- Replacing ChromeOS with MayaOS from inside Crostini in one click
- Guaranteeing `lb build` succeeds on every Chromebook model
- Claiming firmware/UEFI unlock procedures for locked ChromeOS devices

Hardware install of MayaOS on a Chromebook (via developer mode / UEFI) is out of scope for this initialization; document device-specific steps separately if pursued later.
