# Desktop Strategy

## Temporary desktop: XFCE

v0.1 images install **XFCE** with **LightDM** as the display manager.

Why XFCE for now:

- Mature Debian packaging on trixie
- Modest RAM/CPU needs (friendly to QEMU and small hardware)
- Familiar fallback while the custom shell is unfinished

Packages live in `config/package-lists/desktop.list.chroot`. Session defaults and skel hints live under `config/includes.chroot/`.

## Future desktop: Qt/QML Wayland

Long-term MayaOS desktop goals:

1. **Wayland-first** session (no Xorg requirement for the default UI)
2. **Qt Quick / QML** shell: panel, launcher, notifications, settings
3. Compositor either embedded (Qt Wayland compositor) or wlroots-based with a QML client shell

Scaffold:

```
desktop/
├── shell/        # QML application shell (placeholder)
├── compositor/   # Session / compositor notes + stubs
├── protocols/    # Extra protocol XML (optional)
└── theme/        # Visual tokens
```

A placeholder Wayland session desktop file is installed at:

`/usr/share/wayland-sessions/mayaos.desktop`

It is marked experimental and must not be the default until the compositor binary exists and is tested.

## Migration plan (high level)

1. Keep XFCE default in live-build package lists
2. Develop shell against Qt6 on a running Debian/MayaOS system
3. Package `mayaos-shell` + compositor into the image via a new package list
4. Switch LightDM/greeter default session to Maya Wayland
5. Optionally demote XFCE to an alternate session package

## Display server matrix

| Phase | Session | Server |
|-------|---------|--------|
| Current | XFCE | Xorg |
| Transition | XFCE + experimental Wayland entry | Xorg default |
| Target | Maya Shell | Wayland |
