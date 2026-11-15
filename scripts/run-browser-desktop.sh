#!/usr/bin/env bash
# Phase 3.1: run a MayaOS ISO with a browser-accessible VNC desktop.
# Run on a persistent Linux host. Both listeners are loopback-only.
set -euo pipefail
ISO="${1:-}"
if [[ -z "$ISO" || ! -f "$ISO" ]]; then
  echo "Usage: $0 /absolute/path/to/mayaos.iso" >&2
  exit 2
fi
for command in qemu-system-x86_64 websockify; do
  command -v "$command" >/dev/null || { echo "Missing $command; see docs/phase-3-1-browser-access.md" >&2; exit 1; }
done
NOVNC_DIR="${NOVNC_DIR:-/usr/share/novnc}"
[[ -f "$NOVNC_DIR/vnc.html" ]] || { echo "Missing noVNC files at $NOVNC_DIR" >&2; exit 1; }
VNC_DISPLAY="${MAYAOS_VNC_DISPLAY:-1}"
WEB_PORT="${MAYAOS_WEB_PORT:-6080}"
[[ "$VNC_DISPLAY" =~ ^[1-9][0-9]*$ ]] || { echo "Invalid VNC display" >&2; exit 2; }
[[ "$WEB_PORT" =~ ^[0-9]+$ ]] || { echo "Invalid web port" >&2; exit 2; }
ACCEL=tcg
if [[ -r /dev/kvm && -w /dev/kvm ]]; then ACCEL=kvm; fi
echo "Starting MayaOS with $ACCEL acceleration; web UI on 127.0.0.1:$WEB_PORT"
echo "Access from your Chromebook using an SSH tunnel, not a public port."
qemu-system-x86_64 -machine "accel=$ACCEL" -m 2048 -smp 2 \
  -cdrom "$ISO" -boot d -vga std -display none \
  -vnc "127.0.0.1:$VNC_DISPLAY" -nic user,model=e1000 &
QEMU_PID=$!
cleanup() { kill "$QEMU_PID" "${PROXY_PID:-}" 2>/dev/null || true; wait "$QEMU_PID" "${PROXY_PID:-}" 2>/dev/null || true; }
trap cleanup EXIT INT TERM
websockify --web "$NOVNC_DIR" "127.0.0.1:$WEB_PORT" "127.0.0.1:$((5900 + VNC_DISPLAY))" &
PROXY_PID=$!
wait -n "$QEMU_PID" "$PROXY_PID"
