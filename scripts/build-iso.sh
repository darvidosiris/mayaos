#!/usr/bin/env bash
# Configure and build the MayaOS live hybrid ISO with Debian live-build.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/scripts/lib/common.sh"

VERSION="$(mayaos_version "${ROOT}")"
BUILD_DIR="${MAYAOS_BUILD_DIR:-${ROOT}/build}"
OUT_DIR="${MAYAOS_OUT_DIR:-${ROOT}/out}"
DO_CLEAN=0
CONFIG_ONLY=0
SKIP_DEPS=0
FORCE_ROOT_CHECK=1

usage() {
	cat <<'EOF'
Usage: sudo ./scripts/build-iso.sh [options]

Options:
  --clean             lb clean / wipe build tree before configure
  --config-only       Run lb config only (no lb build)
  --skip-deps-check   Do not run check-deps.sh --strict
  --build-dir DIR     Override build directory (default: ./build)
  --out-dir DIR       Override output directory (default: ./out)
  -h, --help          Show help

Environment:
  MAYAOS_SUITE MAYAOS_MIRROR MAYAOS_SECURITY_MIRROR MAYAOS_ARCH
  MAYAOS_BUILD_DIR MAYAOS_OUT_DIR
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--clean) DO_CLEAN=1; shift ;;
		--config-only) CONFIG_ONLY=1; shift ;;
		--skip-deps-check) SKIP_DEPS=1; shift ;;
		--build-dir) BUILD_DIR="$2"; shift 2 ;;
		--out-dir) OUT_DIR="$2"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		*) die "Unknown option: $1" ;;
	esac
done

if [[ "${FORCE_ROOT_CHECK}" -eq 1 && "$(id -u)" -ne 0 ]]; then
	die "ISO build must run as root (try: sudo $0). live-build needs chroot privileges."
fi

if [[ "${SKIP_DEPS}" -eq 0 ]]; then
	# Run deps check as the invoking logic; may warn when optional tools missing.
	if [[ -x "${ROOT}/scripts/check-deps.sh" ]]; then
		log "Running dependency check (strict for build tools)"
		# When root, PATH may differ; still check.
		bash "${ROOT}/scripts/check-deps.sh" --strict || die "Dependency check failed"
	fi
fi

need_cmd lb
need_cmd rsync

FREE="$(free_kib "${BUILD_DIR%/*}")"
MIN_KIB=$((12 * 1024 * 1024))
if [[ -n "${FREE}" && "${FREE}" -lt "${MIN_KIB}" ]]; then
	warn "Low free space ($(human_mib "${FREE}")) — build may fail"
fi

log "MayaOS ${VERSION} — preparing build tree at ${BUILD_DIR}"
mkdir -p "${BUILD_DIR}" "${OUT_DIR}"

# Sync version into includes before rsync
mkdir -p "${ROOT}/config/includes.chroot/etc/mayaos"
printf '%s\n' "${VERSION}" > "${ROOT}/config/includes.chroot/etc/mayaos/version"

# live-build expects to run inside a directory containing auto/ and config/
# We keep source config in repo and sync into BUILD_DIR.
rsync -a --delete \
	--exclude '.git/' \
	"${ROOT}/config/" "${BUILD_DIR}/config/"

# auto/ must live at build root for `lb config`/`lb build`
mkdir -p "${BUILD_DIR}/auto"
rsync -a "${ROOT}/config/auto/" "${BUILD_DIR}/auto/"
chmod +x "${BUILD_DIR}/auto/config" "${BUILD_DIR}/auto/clean" 2>/dev/null || true

# Hooks must be executable
find "${BUILD_DIR}/config/hooks" -type f -name '*.hook.*' -exec chmod +x {} + 2>/dev/null || true
find "${BUILD_DIR}/config/includes.chroot/usr/local/bin" -type f -exec chmod +x {} + 2>/dev/null || true

cd "${BUILD_DIR}"

if [[ "${DO_CLEAN}" -eq 1 ]]; then
	log "Cleaning previous live-build state"
	lb clean --all || lb clean || true
fi

log "Running lb config (suite=${MAYAOS_SUITE:-trixie})"
lb config

if [[ "${CONFIG_ONLY}" -eq 1 ]]; then
	log "Config-only mode complete. Build dir: ${BUILD_DIR}"
	exit 0
fi

log "Running lb build (this can take a long time)"
# Capture status without disabling errexit awkwardly
set +e
lb build 2>&1 | tee "${OUT_DIR}/build-${VERSION}.log"
LB_STATUS=${PIPESTATUS[0]}
set -e

if [[ "${LB_STATUS}" -ne 0 ]]; then
	die "lb build failed with exit ${LB_STATUS}. See ${OUT_DIR}/build-${VERSION}.log"
fi

# Locate ISO artifact
ISO_SRC=""
for cand in \
	"${BUILD_DIR}/live-image-amd64.hybrid.iso" \
	"${BUILD_DIR}/live-image-${MAYAOS_ARCH:-amd64}.hybrid.iso" \
	"${BUILD_DIR}/binary.hybrid.iso" \
	"${BUILD_DIR}/binary.iso"
do
	if [[ -f "${cand}" ]]; then
		ISO_SRC="${cand}"
		break
	fi
done

# Fallback: newest iso in build dir
if [[ -z "${ISO_SRC}" ]]; then
	ISO_SRC="$(find "${BUILD_DIR}" -maxdepth 2 -type f \( -name '*.hybrid.iso' -o -name '*.iso' \) | head -n1 || true)"
fi

if [[ -z "${ISO_SRC}" || ! -f "${ISO_SRC}" ]]; then
	die "Build finished but no ISO found under ${BUILD_DIR}. Inspect the log; do not assume success."
fi

ISO_DEST="${OUT_DIR}/mayaos-${VERSION}-amd64.hybrid.iso"
cp -f "${ISO_SRC}" "${ISO_DEST}"
(cd "${OUT_DIR}" && sha256sum "$(basename "${ISO_DEST}")" > "$(basename "${ISO_DEST}").sha256")

log "ISO published: ${ISO_DEST}"
log "Checksum:      ${ISO_DEST}.sha256"
log "This script does NOT certify bootability. Run: ./scripts/test-qemu.sh ${ISO_DEST}"
exit 0
