#!/usr/bin/env bash
# Smoke-test a MayaOS ISO under QEMU. Does not claim full desktop validation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/scripts/lib/common.sh"

TIMEOUT_SEC=0
MEMORY_MIB="${MAYAOS_QEMU_MEM:-1536}"
SMP="${MAYAOS_QEMU_SMP:-2}"
DISPLAY_MODE="${MAYAOS_QEMU_DISPLAY:-vnc}"  # vnc|sdl|none
VNC_LISTEN="${MAYAOS_VNC:-:1}"
ISO=""
DRY_RUN=0

usage() {
	cat <<'EOF'
Usage: ./scripts/test-qemu.sh [ISO] [options]

  ISO                 Path to hybrid ISO (default: newest out/mayaos-*.iso)
  --timeout SEC       Run at most SEC seconds then stop QEMU (0 = until quit)
  --memory MIB        Guest RAM (default 1536)
  --display MODE      vnc (default), sdl, or none
  --vnc DISPLAY       VNC display such as :1 (default)
  --dry-run           Print QEMU command and exit
  -h, --help          Help

Exit 2 if no ISO; 3 if qemu missing. Success means QEMU launched as requested,
not that XFCE fully appeared — confirm via VNC/console separately.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--timeout) TIMEOUT_SEC="$2"; shift 2 ;;
		--memory) MEMORY_MIB="$2"; shift 2 ;;
		--display) DISPLAY_MODE="$2"; shift 2 ;;
		--vnc) VNC_LISTEN="$2"; shift 2 ;;
		--dry-run) DRY_RUN=1; shift ;;
		-h|--help) usage; exit 0 ;;
		-*) die "Unknown option: $1" ;;
		*) ISO="$1"; shift ;;
	esac
done

if [[ -z "${ISO}" ]]; then
	ISO="$(ls -1t "${ROOT}/out"/mayaos-*.iso "${ROOT}/out"/mayaos-*.hybrid.iso 2>/dev/null | head -n1 || true)"
fi

if [[ -z "${ISO}" || ! -f "${ISO}" ]]; then
	warn "No ISO found. Build one with sudo ./scripts/build-iso.sh or pass a path."
	exit 2
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
	warn "qemu-system-x86_64 not installed (apt install qemu-system-x86)"
	exit 3
fi

ACCEL_ARGS=()
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
	ACCEL_ARGS=(-enable-kvm -cpu host)
	log "Using KVM acceleration"
else
	ACCEL_ARGS=(-cpu qemu64)
	warn "KVM not usable — falling back to TCG (slow)"
fi

DISPLAY_ARGS=()
case "${DISPLAY_MODE}" in
	vnc)
		DISPLAY_ARGS=(-display "vnc=${VNC_LISTEN}")
		log "VNC display ${VNC_LISTEN} (e.g. connect to host:5901 for :1)"
		;;
	sdl)
		DISPLAY_ARGS=(-display sdl)
		;;
	none)
		DISPLAY_ARGS=(-display none -serial stdio)
		;;
	*)
		die "Invalid --display ${DISPLAY_MODE}"
		;;
esac

QEMU_CMD=(
	qemu-system-x86_64
	"${ACCEL_ARGS[@]}"
	-m "${MEMORY_MIB}"
	-smp "${SMP}"
	-cdrom "${ISO}"
	-boot d
	"${DISPLAY_ARGS[@]}"
	-name "MayaOS-smoke"
)

log "ISO: ${ISO}"
log "Command: ${QEMU_CMD[*]}"

if [[ "${DRY_RUN}" -eq 1 ]]; then
	exit 0
fi

warn "Smoke test only — do not treat launch alone as proof of a bootable desktop."

if [[ "${TIMEOUT_SEC}" -gt 0 ]]; then
	need_cmd timeout
	# timeout returns 124 on expiry; treat that as success for smoke window
	set +e
	timeout --signal=TERM "${TIMEOUT_SEC}" "${QEMU_CMD[@]}"
	rc=$?
	set -e
	if [[ "${rc}" -eq 124 ]]; then
		log "QEMU ran for ${TIMEOUT_SEC}s (timeout) — smoke window complete"
		exit 0
	fi
	exit "${rc}"
fi

exec "${QEMU_CMD[@]}"
