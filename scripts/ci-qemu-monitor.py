#!/usr/bin/env python3
"""Capture QEMU boot-screen evidence and advance a default BIOS boot menu."""
import os
import socket
import time

monitor = os.environ.get("MAYAOS_QEMU_MONITOR", "out/qemu-monitor.sock")
output = os.environ.get("MAYAOS_QEMU_OUT", "out")
start = time.monotonic()

def command(cmd):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(5)
            s.connect(monitor)
            s.recv(4096)
            s.sendall((cmd + "\n").encode())
            time.sleep(0.3)
            return s.recv(4096).decode(errors="replace")
    except (OSError, TimeoutError) as exc:
        print(f"QEMU monitor command {cmd!r}: {exc}", flush=True)
        return ""

for at, cmd in [
    (15, "screendump " + os.path.abspath(output + "/qemu-boot-15s.ppm")),
    (17, "sendkey ret"),
    (45, "screendump " + os.path.abspath(output + "/qemu-boot-45s.ppm")),
    (110, "screendump " + os.path.abspath(output + "/qemu-boot-110s.ppm")),
    (180, "screendump " + os.path.abspath(output + "/mayaos-desktop-180s.ppm")),
    (220, "screendump " + os.path.abspath(output + "/mayaos-desktop-220s.ppm")),
]:
    time.sleep(max(0, at - (time.monotonic() - start)))
    print(f"QEMU {at}s: {cmd}: {command(cmd)}", flush=True)

# Capture actual interaction states when the guest reports each verified milestone.
milestones = {
    "MAYAOS_LAUNCHER_OK": "mayaos-launcher-open.ppm",
    "MAYAOS_QUICK_SETTINGS_OK": "mayaos-quick-settings-open.ppm",
    "MAYAOS_WINDOW_LIST_OK": "mayaos-running-window.ppm",
}
captured = set()
while time.monotonic() - start < 235 and len(captured) < len(milestones):
    try:
        with open(output + "/qemu-serial.log", "r", errors="replace") as log:
            serial = log.read()
        for marker, filename in milestones.items():
            if marker in serial and marker not in captured:
                command("screendump " + os.path.abspath(output + "/" + filename))
                captured.add(marker)
                print("Captured " + filename, flush=True)
    except OSError:
        pass
    time.sleep(1)
