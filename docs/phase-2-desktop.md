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

## Phase 2.2 — visual identity
- Navy/gold sunrise SVG wallpaper at `/usr/share/backgrounds/mayaos/mayaos-sunrise.svg`
- Session-scoped XFCE theme and desktop-icon preferences
- XFCE top panel is stopped in the live preview; the MayaOS dock now includes a clock, sound and session controls
- Restore the XFCE panel with `xfce4-panel &` or set `MAYAOS_KEEP_XFCE_PANEL=1` before starting the shell
- This does not remove XFCE packages or replace the display manager

Rebuild the ISO from the Phase 2 branch and inspect `mayaos-desktop-preview` screenshots in the GitHub Actions run artifacts. If the wallpaper is missing, inspect xfdesktop's monitor-specific xfconf properties; not all XFCE configurations use the same paths.

## Phase 2.4 — quick settings preview
The dock now includes a Quick Settings popup displaying NetworkManager connectivity, PulseAudio volume, and UPower battery percentage when available. Buttons open network connection editing, volume controls, and XFCE notification preferences. This is not yet a full system tray or notification history. Notification popups remain provided by xfce4-notifyd. Missing hardware/services display unavailable states rather than fabricated values.

The Phase 2.3 window list also now parses tab-separated window entries correctly. Validate by launching Terminal and Files and checking their taskbar entries, then test the Quick Settings popup interactively. Automated idle screenshots alone do not prove these interactions.
