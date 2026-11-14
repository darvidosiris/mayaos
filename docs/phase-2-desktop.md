# MayaOS Phase 2: desktop interface

This is an initial, reversible desktop-shell preview, **not** a replacement for XFCE.

## Included
- MayaOS dark navy and gold dock
- Searchable application launcher
- Shortcuts to Files, Terminal, Settings, and other installed apps
- Automatic startup in XFCE sessions

## Safety and recovery
XFCE, LightDM, and the original XFCE panel remain installed and usable.
To disable the preview in a running live session:
`pkill -f '^python3 /usr/local/bin/mayaos-shell$'`
To disable it persistently in a customized installation, remove
`/etc/xdg/autostart/mayaos-shell.desktop`.

## Next increments
- Replace the temporary Tk dock with a native Qt/QML shell
- Add wallpaper and appearance controls
- Add tray, notifications, workspace controls, and accessibility testing
- Test real desktop usability in QEMU and on supported hardware
