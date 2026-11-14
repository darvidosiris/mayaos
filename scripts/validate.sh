#!/usr/bin/env bash
# Static validation of MayaOS project structure and scripts.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/scripts/lib/common.sh"

ERRORS=0
warn_count=0

ok()   { echo "[OK] $*"; }
bad()  { echo "[FAIL] $*" >&2; ERRORS=$((ERRORS + 1)); }
soft() { echo "[WARN] $*"; warn_count=$((warn_count + 1)); }

log "MayaOS validate — root ${ROOT}"

# VERSION
if [[ -f "${ROOT}/VERSION" ]]; then
	VER="$(tr -d '[:space:]' < "${ROOT}/VERSION")"
	if [[ "${VER}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.]+)?$ ]]; then
		ok "VERSION=${VER}"
	else
		bad "VERSION format unexpected: '${VER}'"
	fi
else
	bad "VERSION missing"
fi

# Required paths
REQUIRED_PATHS=(
	README.md
	LICENSE
	docs/ARCHITECTURE.md
	docs/BUILD.md
	docs/CHROMEBOOK.md
	docs/DESKTOP.md
	docs/TESTING.md
	docs/LIMITATIONS.md
	config/auto/config
	config/auto/clean
	config/package-lists/mayaos.list.chroot
	config/package-lists/desktop.list.chroot
	config/hooks/live/0010-mayaos-branding.hook.chroot
	config/hooks/live/0020-mayaos-defaults.hook.chroot
	config/includes.chroot/etc/mayaos/version
	config/includes.chroot/usr/local/bin/mayaos-session
	config/includes.chroot/usr/local/bin/mayaos-info
	config/includes.chroot/usr/share/wayland-sessions/mayaos.desktop
	desktop/README.md
	scripts/check-chromebook.sh
	scripts/check-deps.sh
	scripts/build-iso.sh
	scripts/test-qemu.sh
	scripts/validate.sh
	.github/workflows/build-iso.yml
)

for p in "${REQUIRED_PATHS[@]}"; do
	if [[ -e "${ROOT}/${p}" ]]; then
		ok "exists ${p}"
	else
		bad "missing ${p}"
	fi
done

# Scripts executable + bash -n
SCRIPTS=(
	scripts/check-chromebook.sh
	scripts/check-deps.sh
	scripts/build-iso.sh
	scripts/test-qemu.sh
	scripts/validate.sh
	scripts/lib/common.sh
	config/auto/config
	config/auto/clean
	config/hooks/live/0010-mayaos-branding.hook.chroot
	config/hooks/live/0020-mayaos-defaults.hook.chroot
	config/hooks/normal/0010-mayaos-branding.hook.chroot
	config/includes.chroot/usr/local/bin/mayaos-session
	config/includes.chroot/usr/local/bin/mayaos-info
)

for s in "${SCRIPTS[@]}"; do
	path="${ROOT}/${s}"
	[[ -f "${path}" ]] || continue
	if [[ -x "${path}" ]]; then
		ok "executable ${s}"
	else
		soft "not executable yet: ${s}"
	fi
	case "${s}" in
		*.sh|scripts/*)
			if bash -n "${path}" 2>/tmp/mayaos-bash-n.err; then
				ok "bash -n ${s}"
			else
				bad "bash -n ${s}: $(cat /tmp/mayaos-bash-n.err)"
			fi
			;;
		config/auto/*)
			if sh -n "${path}" 2>/tmp/mayaos-sh-n.err; then
				ok "sh -n ${s}"
			else
				bad "sh -n ${s}: $(cat /tmp/mayaos-sh-n.err)"
			fi
			;;
		*.hook.chroot|*/mayaos-session|*/mayaos-info)
			if sh -n "${path}" 2>/tmp/mayaos-sh-n.err; then
				ok "sh -n ${s}"
			else
				bad "sh -n ${s}: $(cat /tmp/mayaos-sh-n.err)"
			fi
			;;
	esac
done

# auto/config should mention trixie and iso-hybrid
if grep -q 'trixie' "${ROOT}/config/auto/config" && grep -q 'iso-hybrid' "${ROOT}/config/auto/config"; then
	ok "live-build auto/config targets trixie iso-hybrid"
else
	bad "auto/config missing trixie or iso-hybrid"
fi

# Desktop phase marker
if grep -q 'xfce-temporary' "${ROOT}/config/includes.chroot/etc/mayaos/desktop-phase"; then
	ok "desktop-phase is xfce-temporary"
else
	soft "desktop-phase unexpected"
fi

# Refuse to claim a bootable ISO exists
if ls "${ROOT}/out"/*.iso >/dev/null 2>&1; then
	soft "ISO artifact(s) present under out/ — bootability still requires QEMU/hardware tests"
else
	ok "no ISO under out/ (expected before first successful build)"
fi

echo
if [[ "${ERRORS}" -gt 0 ]]; then
	die "Validation failed with ${ERRORS} error(s), ${warn_count} warning(s)"
fi
log "Validation passed (${warn_count} warning(s))"
exit 0
