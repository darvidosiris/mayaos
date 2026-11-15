#!/usr/bin/env bash
# Download the latest available MayaOS ISO artifact and start the browser desktop.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${CODESPACES:-}" != "true" ]]; then
  echo "This helper is designed for GitHub Codespaces." >&2
  exit 1
fi
command -v gh >/dev/null || { echo "Missing GitHub CLI (gh)." >&2; exit 1; }
command -v unzip >/dev/null || { echo "Missing unzip." >&2; exit 1; }
ARTIFACT_DIR="${ROOT}/out/codespaces"
mkdir -p "$ARTIFACT_DIR"
echo "Downloading the newest available MayaOS ISO workflow artifact..."
RUN_ID="$(gh run list --repo darvidosiris/mayaos --workflow build-iso.yml --branch feature/phase2-mayaos-desktop-shell --event workflow_dispatch --status success --limit 10 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)"
if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
  echo "No successful manual ISO build run found on the MayaOS feature branch." >&2
  echo "Run the Build ISO workflow on that branch first." >&2
  exit 1
fi
if ! gh run download "$RUN_ID" --repo darvidosiris/mayaos --name mayaos-iso --dir "$ARTIFACT_DIR"; then
  echo "Unable to download an ISO. Build one at https://github.com/darvidosiris/mayaos/actions/workflows/build-iso.yml" >&2
  echo "Choose branch feature/phase2-mayaos-desktop-shell and enable Build ISO. Then retry this command." >&2
  exit 1
fi
ISO="$(find "$ARTIFACT_DIR" -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO" ]]; then
  echo "Artifact did not contain an .iso file. Run the full Build ISO GitHub workflow." >&2
  exit 1
fi
echo "ISO found: $ISO"
echo "When port 6080 appears in the Codespaces PORTS panel, choose Open in Browser."
echo "Keep visibility PRIVATE. The browser address ends with /vnc.html."
export MAYAOS_WEB_BIND=0.0.0.0
exec bash "$ROOT/scripts/run-browser-desktop.sh" "$ISO"
