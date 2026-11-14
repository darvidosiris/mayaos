# MayaOS Desktop (future)

This tree holds the **custom Qt/QML Wayland desktop**. It is **not** the current default session.

Current shipping desktop: **XFCE** (see `config/package-lists/desktop.list.chroot`).

## Layout

| Path | Purpose |
|------|---------|
| `shell/` | QML shell (panel, launcher, settings) |
| `compositor/` | Wayland compositor / session integration |
| `protocols/` | Optional Wayland protocol definitions |
| `theme/` | Colors, typography tokens, assets |

## Development deps (host, not live ISO)

```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qt6-wayland-dev \
  qml6-module-qtquick qml6-module-qtquick-controls cmake g++
```

Live images carry **runtime** Qt6/QML modules only, plus a stub `mayaos-session` that exits until a real compositor is packaged.

## Milestone sketch

1. Hello-world QML window under X11/Wayland on Debian
2. Minimal compositor session + `.desktop` that starts successfully
3. Package `.deb` and add to live-build package list
4. Flip LightDM default from `xfce` → Maya session
5. Update `/etc/mayaos/desktop-phase` to `maya-wayland`
