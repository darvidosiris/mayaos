#!/usr/bin/env bash
# Verify host packages/tools needed to configure or build MayaOS.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/scripts/lib/common.sh"

STRICT=0
INSTALL_HINT=1

usage() {
	cat <<'EOF'
Usage: check-deps.sh [--strict] [--no-hint]

  --strict    Exit non-zero if any required build tool is missing
  --no-hint   Do not print apt install hint
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--strict) STRICT=1; shift ;;
		--no-hint) INSTALL_HINT=0; shift ;;
		-h|--help) usage; exit 0 ;;
		*) die "Unknown option: $1" ;;
	esac
done

REQUIRED=(bash rsync sha256sum)
BUILD_REQUIRED=(lb debootstrap xorriso mksquashfs)
BUILD_OPTIONAL=(qemu-system-x86_64)

MISSING_REQ=()
MISSING_BUILD=()
MISSING_OPT=()

check_list() {
	local -n arr=$1
	local -n miss=$2
	local c
	for c in "${arr[@]}"; do
		if command -v "$c" >/dev/null 2>&1; then
			echo "[+] $c"
		else
			echo "[ ] $c"
			miss+=("$c")
		fi
	done
}

log "MayaOS dependency check"
echo
log "Always required"
check_list REQUIRED MISSING_REQ

echo
log "Required for ISO build"
check_list BUILD_REQUIRED MISSING_BUILD

echo
log "Optional (QEMU testing)"
check_list BUILD_OPTIONAL MISSING_OPT

# Extra: live-build related packages often needed but not a single binary name
echo
log "Related packages (dpkg, best-effort)"
if command -v dpkg >/dev/null 2>&1; then
	for pkg in live-build debootstrap squashfs-tools xorriso isolinux \
		grub-pc-bin grub-efi-amd64-bin mtools dosfstools; do
		if dpkg -s "$pkg" >/dev/null 2>&1; then
			echo "[+] package $pkg"
		else
			echo "[ ] package $pkg"
		fi
	done
else
	warn "dpkg not available; skipped package inventory"
fi

echo
if [[ ${#MISSING_REQ[@]} -gt 0 ]]; then
	warn "Missing base tools: ${MISSING_REQ[*]}"
fi
if [[ ${#MISSING_BUILD[@]} -gt 0 ]]; then
	warn "Missing ISO build tools: ${MISSING_BUILD[*]}"
fi
if [[ ${#MISSING_OPT[@]} -gt 0 ]]; then
	warn "Missing optional tools: ${MISSING_OPT[*]}"
fi

if [[ "${INSTALL_HINT}" -eq 1 ]]; then
	cat <<'EOF'

Suggested install (Debian/Ubuntu amd64):
  sudo apt-get update
  sudo apt-get install -y live-build debootstrap squashfs-tools xorriso \
    isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin \
    mtools dosfstools ca-certificates curl rsync qemu-system-x86
EOF
fi

if [[ ${#MISSING_REQ[@]} -gt 0 ]]; then
	exit 1
fi
if [[ "${STRICT}" -eq 1 && ${#MISSING_BUILD[@]} -gt 0 ]]; then
	exit 1
fi
exit 0
