# Build & environment limitations

Captured at project initialization on a Crostini (Chromebook) Debian 12 host. Re-run the check scripts on your machine for current numbers.

## Host observed at init

| Factor | Observation | Impact |
|--------|-------------|--------|
| Host OS | Debian 12 (bookworm) | Building **trixie** needs network + capable debootstrap |
| Environment | Chromebook Crostini (`chronos-access`, `penguin`) | Loop mounts / nested virt may block `lb build` |
| Free disk | Often &lt; 15 GiB on default disks | ISO builds frequently fail with ENOSPC |
| RAM | ~2–4 GiB typical | Avoid concurrent heavy QEMU + live-build |
| Tools | `live-build`, `qemu-system-x86`, `debootstrap` may be unset | Install per `docs/BUILD.md` |
| KVM | `/dev/kvm` may be present | Helps QEMU; does not guarantee live-build success |

## Project / process limitations

1. **No prebuilt ISO** is shipped; nothing is declared bootable until QEMU or hardware testing.
2. **No ZIP download requirement** — source and scripts are the distribution method for the build system.
3. **XFCE is temporary**; the Wayland session file is a stub that exits until a compositor exists.
4. **CI ISO builds** are opt-in (`workflow_dispatch`) because they are long and disk-heavy; Ubuntu runners may need a newer debootstrap for suite `trixie`.
5. **Debian installer** is disabled (`--debian-installer none`) in v0.1 — image is live/hybrid focused; calamares/installer can be added later.
6. **amd64 only** in the first configuration.

## What validation covers

`./scripts/validate.sh` checks structure and shell syntax. It does **not** build an ISO or boot a VM.
