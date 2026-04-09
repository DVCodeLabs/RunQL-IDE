#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <extension-version> <vsix-target> <overlay|vscode> [stable|insider]" >&2
  exit 1
fi

EXTENSION_VERSION="${1#v}"
VSIX_TARGET="$2"
MODE="$3"
QUALITY="${4:-stable}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNQL_CLIENT_REPO="${RUNQL_CLIENT_REPO:-DVCodeLabs/RunQL}"
TMP_DIR="$(mktemp -d)"
VSIX_FILENAME="runql-${VSIX_TARGET}-${EXTENSION_VERSION}.vsix"
VSIX_URL="https://github.com/${RUNQL_CLIENT_REPO}/releases/download/v${EXTENSION_VERSION}/${VSIX_FILENAME}"
VSIX_PATH="${TMP_DIR}/${VSIX_FILENAME}"
IMPORT_DIR="${TMP_DIR}/imported"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

patch_manifest() {
  local package_json="$1"
  node - "${package_json}" <<'NODE'
const fs = require('fs');
const file = process.argv[2];
const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
const activationEvents = new Set(pkg.activationEvents || []);
activationEvents.add('onCommand:runql.welcome.open');
pkg.activationEvents = Array.from(activationEvents);
fs.writeFileSync(file, `${JSON.stringify(pkg, null, 2)}\n`);
NODE
}

prepare_extension_dir() {
  local extension_dir="$1"

  rm -rf "${extension_dir}/node_modules"
  (
    cd "${extension_dir}"
    npm install --omit=dev
  )
}

echo "Downloading ${VSIX_URL}"
curl -L --fail --output "${VSIX_PATH}" "${VSIX_URL}"

unzip -q "${VSIX_PATH}" -d "${IMPORT_DIR}"

if [[ ! -f "${IMPORT_DIR}/extension/package.json" ]]; then
  echo "Invalid VSIX: missing extension/package.json" >&2
  exit 1
fi

case "${MODE}" in
  overlay)
    "${ROOT_DIR}/dev/import-runql-client-vsix.sh" "${VSIX_PATH}" "${QUALITY}"
    "${ROOT_DIR}/dev/prepare-runql-client-extension.sh" "${QUALITY}"
    ;;
  vscode)
    DEST_DIR="${ROOT_DIR}/vscode/extensions/runql-client"

    if [[ ! -d "${ROOT_DIR}/vscode" ]]; then
      echo "Missing ${ROOT_DIR}/vscode directory" >&2
      exit 1
    fi

    rm -rf "${DEST_DIR}"
    mkdir -p "${DEST_DIR}"
    cp -R "${IMPORT_DIR}/extension/." "${DEST_DIR}/"
    patch_manifest "${DEST_DIR}/package.json"
    prepare_extension_dir "${DEST_DIR}"
    ;;
  *)
    echo "Invalid mode: ${MODE}" >&2
    exit 1
    ;;
esac
