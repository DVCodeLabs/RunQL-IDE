#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <path-to-runql-client.vsix> [stable|insider|both]" >&2
  exit 1
fi

VSIX_PATH="$1"
TARGET="${2:-stable}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if [[ ! -f "${VSIX_PATH}" ]]; then
  echo "VSIX not found: ${VSIX_PATH}" >&2
  exit 1
fi

case "${TARGET}" in
  stable|insider|both)
    ;;
  *)
    echo "Invalid target: ${TARGET}" >&2
    exit 1
    ;;
esac

unzip -q "${VSIX_PATH}" -d "${TMP_DIR}"

if [[ ! -f "${TMP_DIR}/extension/package.json" ]]; then
  echo "Invalid VSIX: missing extension/package.json" >&2
  exit 1
fi

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

import_target() {
  local quality="$1"
  local dest="${ROOT_DIR}/src/${quality}/extensions/runql-client"

  rm -rf "${dest}"
  mkdir -p "${dest}"
  cp -R "${TMP_DIR}/extension/." "${dest}/"
  patch_manifest "${dest}/package.json"

  echo "Imported RunQL client into src/${quality}/extensions/runql-client"
}

if [[ "${TARGET}" == "stable" || "${TARGET}" == "both" ]]; then
  import_target stable
fi

if [[ "${TARGET}" == "insider" || "${TARGET}" == "both" ]]; then
  import_target insider
fi
