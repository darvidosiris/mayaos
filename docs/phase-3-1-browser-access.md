# Phase 3.1 — Interactive MayaOS in a browser

The GitHub Actions screenshots are not interactive. This adds a QEMU + noVNC launcher for a **persistent Linux host** so a Chromebook can control MayaOS from its browser. It does **not** deploy a VM or provide a public URL automatically.

## Host requirements

A Linux VM/server or PC with Ubuntu/Debian, 4 GB RAM recommended, and the MayaOS ISO from the GitHub Actions **mayaos-iso** artifact. Hardware virtualization (/dev/kvm) is optional; software emulation is much slower. The host must remain powered on while you use MayaOS.

Install prerequisites on the host:

```bash
sudo apt-get update
sudo apt-get install -y qemu-system-x86 novnc websockify
```

Download the latest successful ISO artifact from the GitHub Actions workflow and unzip it on the host. Then clone or update the MayaOS repo on the Phase 3 branch and run:

```bash
chmod +x scripts/run-browser-desktop.sh
./scripts/run-browser-desktop.sh /absolute/path/to/mayaos.iso
```

The script starts a QEMU VM and a noVNC browser endpoint **only on 127.0.0.1** (port 6080). It intentionally does not expose the VM to the public internet.

## Connect from a Chromebook

From the Chromebook Linux terminal, establish an SSH tunnel to the Linux host:

```bash
ssh -N -L 6080:127.0.0.1:6080 USER@YOUR_LINUX_HOST
```

Then visit **http://127.0.0.1:6080/vnc.html** in the Chromebook browser and click **Connect**. The tunnel requires an SSH-reachable host and valid SSH credentials. If Chromebook Linux is unavailable, use an authenticated private reverse proxy with HTTPS and access control rather than opening port 6080 publicly.

## Safety and limitations

- Never publicly expose the VNC port (5901) or the noVNC port (6080) without strong authentication and encryption. This launcher is deliberately localhost-only.
- The ISO is a live session: changes may disappear after shutdown. This phase does not add a persistent installed system.
- GitHub Actions runners are ephemeral and cannot host a continuously accessible desktop.
- QEMU's default user-mode networking is sufficient for basic outbound access; it does not expose inbound services.
- Stop the launcher with Ctrl+C. A dedicated persistent VM, authentication, and HTTPS can be added after the first interactive test.

## Verification

1. Check the script syntax: `bash -n scripts/run-browser-desktop.sh`.
2. Confirm noVNC loads through the SSH tunnel and MayaOS reaches the desktop.
3. Click **MayaOS**, open **System Settings**, and test Files, Quick Settings, and the dock.
4. Keep the existing ISO/QEMU GitHub CI checks passing; they remain separate from this browser-access workflow.
