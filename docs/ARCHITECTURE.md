# MayaOS Architecture

## Goals

- Ship a Debian 13 (trixie) amd64 live/installable ISO.
- Use XFCE as a **temporary** production desktop while the custom shell matures.
- Isolate OS image construction (live-build) from desktop UI code (`desktop/`).
- Remain developable on Chromebooks (Crostini) with honest capability checks.

## Layers

```
┌─────────────────────────────────────────────┐
│  Applications (user / Flatpak later)        │
├─────────────────────────────────────────────┤
│  Desktop session                            │
│    NOW:  XFCE (X11 session via lightdm)     │
│    NEXT: Maya Shell (Qt/QML) + Wayland      │
├─────────────────────────────────────────────┤
│  Display / input                            │
│    XFCE path: Xorg                          │
│    Future:    wlroots-class or Qt compositor│
├─────────────────────────────────────────────┤
│  MayaOS branding & defaults (/etc/mayaos)   │
├─────────────────────────────────────────────┤
│  Debian 13 (trixie) userland + Linux kernel │
└─────────────────────────────────────────────┘
```

## Image construction

MayaOS images are produced with **Debian live-build** (`lb config` / `lb build`).

| Path | Role |
|------|------|
| `config/auto/config` | Canonical `lb config` flags (suite, desktop, hybrid ISO) |
| `config/package-lists/` | Apt package sets for base + XFCE |
| `config/hooks/` | Chroot/binary customization |
| `config/includes.chroot/` | Files dropped into the rootfs |
| `scripts/build-iso.sh` | Orchestrates clean/config/build and copies artifacts to `out/` |

Build working directory defaults to `build/` (generated, gitignored). Source of truth for live-build config remains the repo `config/` tree, which is synced into the build tree before `lb build`.

## Branding identity

- OS name: **MayaOS**
- Codename path: `/etc/mayaos/`
- `os-release` fields overridden via hook (NAME, PRETTY_NAME, ID, ID_LIKE)
- Version string from repo `VERSION` file injected at build time

## Future desktop (Qt/QML Wayland)

Scaffold under `desktop/`:

| Component | Intent |
|-----------|--------|
| `desktop/shell/` | Panel, launcher, settings UI (QML) |
| `desktop/compositor/` | Wayland compositor integration / session |
| `desktop/protocols/` | Extra Wayland protocols if needed |
| `desktop/theme/` | Icons, colors, QML style |

Until the compositor session is installable as a `.desktop` Wayland session, XFCE remains the default login session. A placeholder Wayland session file ships under `config/includes.chroot/.../wayland-sessions/` marked experimental.

## Chromebook development host

Chromebook (Crostini) is a **host** for editing and limited testing, not the target install platform by default. See [CHROMEBOOK.md](CHROMEBOOK.md). Target media are ordinary UEFI/BIOS x86-64 PCs and VMs.

## Non-goals (v0.1)

- Claiming a bootable ISO without QEMU/hardware validation
- Shipping a finished custom compositor
- Supporting non-amd64 architectures in the first ISO
