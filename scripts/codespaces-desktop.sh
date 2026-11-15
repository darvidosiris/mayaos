#!/usr/bin/env bash
# Find an actual downloadable MayaOS ISO artifact, then start QEMU + noVNC.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="darvidosiris/mayaos"
ARTIFACT_DIR="${ROOT}/out/codespaces"
mkdir -p "$ARTIFACT_DIR"
if [[ "${CODESPACES:-}" != "true" ]]; then
  echo "This helper is designed for GitHub Codespaces." >&2
  exit 1
fi
command -v gh >/dev/null || { echo "Missing GitHub CLI (gh)." >&2; exit 1; }
if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Reuse a local ISO if one has already been downloaded.
ISO="$(find "$ARTIFACT_DIR" -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO" ]]; then
  echo "Searching GitHub Actions for a downloadable mayaos-iso artifact..."
  # Artifact lookup is more reliable than filtering runs by event/branch/status:
  # the run may be associated with a pull_request or the default branch.
  # Use artifact IDs directly: workflow_run can be null on some artifact records,
  # and gh run download may fail even when the artifact itself is available.
  ARTIFACT_ID="$(gh api "repos/$REPO/actions/artifacts?per_page=100" \
    --jq '[.artifacts[] | select(.name == "mayaos-iso" and .expired == false)] | sort_by(.created_at) | reverse | .[0].id // empty')"
  if [[ -z "$ARTIFACT_ID" ]]; then
    echo "No unexpired mayaos-iso artifact found. A green Validate job alone does not produce an ISO." >&2
    echo "Check Build live ISO and Upload ISO artifacts at https://github.com/$REPO/actions/workflows/build-iso.yml" >&2
    gh run list --repo "$REPO" --workflow build-iso.yml --limit 10 || true
    exit 1
  fi
  echo "Found ISO artifact ID $ARTIFACT_ID. Downloading ZIP directly..."
  ZIP_PATH="$ARTIFACT_DIR/mayaos-iso-$ARTIFACT_ID.zip"
  if ! gh api "repos/$REPO/actions/artifacts/$ARTIFACT_ID/zip" > "$ZIP_PATH"; then
    rm -f "$ZIP_PATH"
    echo "GitHub API artifact download failed; error shown above. Verify gh auth status and artifact access." >&2
    exit 1
  fi
  if ! unzip -tq "$ZIP_PATH" >/dev/null; then
    echo "Downloaded artifact is not a valid ZIP. Check API authentication and artifact availability." >&2
    rm -f "$ZIP_PATH"
    exit 1
  fi
  unzip -o "$ZIP_PATH" -d "$ARTIFACT_DIR"
  rm -f "$ZIP_PATH"
  ISO="$(find "$ARTIFACT_DIR" -type f -name '*.iso' -print -quit)"
fi
if [[ -z "$ISO" ]]; then
  echo "Artifact was downloaded but contains no .iso file. Verify the Build live ISO job succeeded." >&2
  exit 1
fi
echo "ISO found: $ISO"
echo "In Codespaces PORTS, open port 6080 and keep its visibility PRIVATE."
echo "Open the forwarded HTTPS URL ending in /vnc.html."
export MAYAOS_WEB_BIND=0.0.0.0
exec bash "$ROOT/scripts/run-browser-desktop.sh" "$ISO"
