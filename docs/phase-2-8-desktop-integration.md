# Phase 2.8 — Desktop integration

This phase improves consistency while preserving the existing XFCE window manager and native Qt Quick MayaOS dock.

- The GTK 3 default settings prefer a dark application theme, consistent fonts, and familiar window controls. Qt Quick dock styling remains navy and gold. Existing user preferences may override these system defaults.
- The QEMU guest interaction test now checks that Thunar is present in the EWMH task list, minimizes through `mayaos-windowctl`, and restores through the same controller.
- CI requires `MAYAOS_WINDOW_CONTROLS_OK` in addition to the earlier Phase 2.7 milestones.

## Validation

Run the Build ISO workflow on `feature/phase2-mayaos-desktop-shell`. Inspect `mayaos-desktop-preview` screenshots and `qemu-serial.log`. A successful run must include `MAYAOS_INTERACTION_OK` and `MAYAOS_WINDOW_CONTROLS_OK`. Visually inspect Thunar window decorations and the dark GTK theme: GTK defaults are not a guarantee that every XFCE or Qt application uses identical colors.

## Follow-up

Consider a dedicated MayaOS GTK/xfwm4 theme and dock overflow handling after the current integration checks pass.
