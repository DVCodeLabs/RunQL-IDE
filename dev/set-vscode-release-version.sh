#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_JSON="${ROOT_DIR}/vscode/package.json"

if [[ -z "${RELEASE_VERSION:-}" ]]; then
  echo "Missing RELEASE_VERSION" >&2
  exit 1
fi

if [[ ! -f "${PACKAGE_JSON}" ]]; then
  echo "Missing ${PACKAGE_JSON}" >&2
  exit 1
fi

node - "${PACKAGE_JSON}" "${RELEASE_VERSION%-insider}" <<'NODE'
const fs = require('fs');
const [file, version] = process.argv.slice(2);
const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
pkg.version = version;
fs.writeFileSync(file, `${JSON.stringify(pkg, null, 2)}\n`);
NODE
