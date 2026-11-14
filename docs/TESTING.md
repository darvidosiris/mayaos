# Testing MayaOS

## Philosophy

No ISO is described as bootable until it has been exercised. Local scripts and CI separate:

1. **Static validation** — scripts, config presence, shell syntax (`./scripts/validate.sh`)
2. **Image build** — live-build produces an ISO artifact
3. **Runtime smoke** — QEMU boot attempt against that artifact

## Static validation

```bash
./scripts/validate.sh
```

Checks executable bits, `bash -n` on scripts, required config files, and VERSION format.

## QEMU smoke test

After `out/*.iso` (or `out/*.hybrid.iso`) exists:

```bash
./scripts/test-qemu.sh
./scripts/test-qemu.sh /path/to/mayaos.iso
./scripts/test-qemu.sh --timeout 120   # boot window then stop
```

Defaults:

- Prefer KVM (`-enable-kvm`) when `/dev/kvm` is usable
- Fall back to TCG with a warning (slow)
- Use a modest memory size suitable for small hosts
- Prefer VNC or serial/monitor over SDL on Chromebook

Exit codes:

| Code | Meaning |
|------|---------|
| 0 | QEMU started and ran for the requested window (or user quit) |
| 2 | No ISO found |
| 3 | QEMU binary missing |
| other | QEMU failure |

A successful smoke test means the hypervisor launched the guest with the ISO attached — **not** that the desktop session fully came up. Confirm XFCE/login visually (VNC/Spice) or via serial when configured.

## CI

`.github/workflows/build-iso.yml`:

- Runs validate on pull requests
- Optionally builds an ISO on `main` / workflow_dispatch (long-running, large disk)
- Uploads artifacts when a build job succeeds

CI does not automatically assert “bootable desktop”; treat artifacts as **candidates** until QEMU/hardware confirmation.

## Manual checklist (post-ISO)

- [ ] GRUB/Isolinux menu appears
- [ ] Live session reaches graphical login or desktop
- [ ] Networking works
- [ ] `cat /etc/os-release` shows MayaOS branding
- [ ] Shutdown/reboot clean
