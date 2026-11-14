#!/usr/bin/env bash
# Detect Chromebook/Crostini environment and report MayaOS build implications.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/scripts/lib/common.sh"

SCORE=0
IS_CROSTINI=0

log "MayaOS Chromebook / host compatibility check"
echo "Host date context: $(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date)"
echo "Kernel: $(uname -srm)"
echo "OS: $(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
echo

# --- Detection ---
if id -nG 2>/dev/null | grep -qw chronos-access; then
	echo "[+] chronos-access group present (Crostini signal)"
	IS_CROSTINI=1
	SCORE=$((SCORE + 1))
fi

if [[ -d /mnt/chromeos ]]; then
	echo "[+] /mnt/chromeos present"
	IS_CROSTINI=1
	SCORE=$((SCORE + 1))
fi

if [[ -e /dev/.cros_milestone ]] || [[ -f /etc/chromium/fonts ]]; then
	echo "[+] ChromeOS milestone / chromium host markers present"
	IS_CROSTINI=1
	SCORE=$((SCORE + 1))
fi

if [[ "$(hostname -s 2>/dev/null || hostname)" == "penguin" ]]; then
	echo "[+] hostname is penguin (common Crostini default)"
	IS_CROSTINI=1
	SCORE=$((SCORE + 1))
fi

if [[ "${IS_CROSTINI}" -eq 1 ]]; then
	echo
	log "Verdict: likely Chromebook Crostini development host"
else
	echo
	log "Verdict: not detected as Crostini (ordinary Linux host assumptions OK)"
fi

# --- Resources ---
echo
log "Resources"

if [[ -e /dev/kvm ]]; then
	if [[ -r /dev/kvm ]] && [[ -w /dev/kvm ]]; then
		echo "[+] /dev/kvm accessible (KVM acceleration possible)"
	else
		echo "[!] /dev/kvm exists but not RW for current user — add user to kvm group"
	fi
else
	echo "[!] /dev/kvm missing — QEMU will be TCG-only (slow)"
fi

FREE="$(free_kib "${ROOT}")"
echo "[i] Free space on repo volume: $(human_mib "${FREE}")"
MIN_KIB=$((15 * 1024 * 1024))
if [[ "${FREE}" -lt "${MIN_KIB}" ]]; then
	warn "Less than ~15 GiB free — full live-build ISO generation is likely to fail"
	if [[ "${IS_CROSTINI}" -eq 1 ]]; then
		warn "Resize the Linux disk in ChromeOS Settings, or build via GitHub Actions"
	fi
else
	echo "[+] Disk space looks adequate for an ISO build attempt"
fi

MEM_MIB="$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
echo "[i] MemTotal: ${MEM_MIB} MiB"
if [[ "${MEM_MIB}" -gt 0 && "${MEM_MIB}" -lt 3000 ]]; then
	warn "Low RAM for simultaneous live-build + QEMU desktop; prefer CI for ISO builds"
fi

# --- Tooling hints ---
echo
log "Tooling (presence only)"
for c in lb debootstrap qemu-system-x86_64 xorriso squashfs-tools mksquashfs; do
	if command -v "$c" >/dev/null 2>&1; then
		echo "[+] $c"
	else
		echo "[ ] $c (missing)"
	fi
done

echo
log "Recommendations"
if [[ "${IS_CROSTINI}" -eq 1 ]]; then
	cat <<'EOF'
- Use this environment for editing + ./scripts/validate.sh
- Prefer GitHub Actions for producing ISOs when disk/loop mounts fail
- After an ISO exists, smoke-test with ./scripts/test-qemu.sh (VNC)
- Do not assume MayaOS can replace ChromeOS from inside Crostini
EOF
else
	cat <<'EOF'
- Install live-build stack per docs/BUILD.md
- Run sudo ./scripts/build-iso.sh when ready
- Validate with ./scripts/test-qemu.sh before calling an image bootable
EOF
fi

exit 0
