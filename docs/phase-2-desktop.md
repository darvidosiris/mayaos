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

## Phase 2.5 — Qt Quick native preview
The default XFCE autostart entry launches `mayaos-shell-start`, which tries the PySide6 Qt Quick shell and falls back to the proven Tk dock if Qt fails to initialize. The native dock includes app shortcuts, searchable launcher, EWMH running-window list, clock, and quick settings. The XFCE window manager and LightDM remain in place. Qt startup failures are logged to `/tmp/mayaos-qt-shell.log`.

Set `MAYAOS_SHELL_BACKEND=tk` to force the previous dock. This is a native Qt Quick **preview**, not a complete compositor or Wayland desktop environment. Test the new build in QEMU and verify that the Qt shell—not the Tk fallback—is running before considering this phase validated.

## Phase 2.6 — responsive layout and keyboard accessibility
- Qt Quick dock adjusts spacing at narrower screen widths and hides the redundant Settings shortcut under 800px; Settings remains in the launcher.
- Launcher can be toggled with Ctrl+Space while the Qt shell has keyboard focus; Escape closes launcher and quick settings. The search field takes focus when the launcher opens.
- Buttons expose accessible names and show a gold focus outline when keyboard-focused; hover tooltips identify actions.
- Launcher and quick settings constrain width to the available display. Motion is conservative by default.
- The Qt dock still uses XFCE as window manager; this does not yet establish system-wide global shortcuts, a full notification tray, or accessibility certification.

Validation: run the Phase 2 ISO workflow, confirm that the Qt dock appears rather than Tk fallback, then interactively test Tab, Shift+Tab, Enter/Space, launcher search, Escape, and narrower resolutions. Screenshots alone cannot certify accessibility or shortcut operation.
