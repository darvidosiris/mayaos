# MayaOS Phase 3.0 — System Settings

Phase 3 begins with a MayaOS-owned System Settings dashboard in the native Qt Quick shell. The dock Settings button and launcher System Settings item open the same frameless navy-and-gold panel.

The dashboard displays the current Network/Volume status and launches installed XFCE tools for Appearance, Display, Network, Sound, Notifications, and All XFCE Settings. It does not claim to replace their underlying configuration services. Existing launcher, Quick Settings, window management, and desktop functionality remain in place.

## Validation

1. Run project validation and the full ISO/QEMU workflow on `feature/phase2-mayaos-desktop-shell`.
2. Verify the existing boot, Qt shell, launcher, Quick Settings, and window-control markers.
3. Open **Settings** from the dock; confirm the **MayaOS System Settings** panel appears without XFCE window decorations.
4. Open Appearance and Display to confirm their installed configuration utilities launch; close the hub using **Close**.

The CI currently tests the existing Phase 2 interactions, not this new Settings dashboard; manual UI verification is required until a dedicated automated test is added.
