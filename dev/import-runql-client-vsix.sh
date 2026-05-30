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

patch_welcome_app() {
  local extension_dir="$1"
  local welcome_app="${extension_dir}/dist/welcomeApp.js"

  if [[ ! -f "${welcome_app}" ]]; then
    return
  fi

  node - "${welcome_app}" <<'NODE'
const fs = require('fs');
const file = process.argv[2];
let source = fs.readFileSync(file, 'utf8');
const guideUrl = 'https://github.com/DVCodeLabs/RunQL-IDE/blob/main/docs/ext-github-copilot.md';

if (!source.includes(guideUrl)) {
  const documentationNeedle = '"Getting Started Guide")),z.default.createElement("li",null,z.default.createElement("a",{style:p.link,href:"https://github.com/DVCodeLabs/RunQL",target:"_blank"},"Community & Support"))';
  const documentationReplacement = `"Getting Started Guide")),z.default.createElement("li",null,z.default.createElement("a",{style:p.link,href:"${guideUrl}",target:"_blank"},"GitHub Copilot in RunQL")),z.default.createElement("li",null,z.default.createElement("a",{style:p.link,href:"https://github.com/DVCodeLabs/RunQL",target:"_blank"},"Community & Support"))`;
  if (source.includes(documentationNeedle)) {
    source = source.replace(documentationNeedle, documentationReplacement);
  } else {
    console.warn('RunQL welcome documentation list insertion point not found; skipping Copilot documentation-list link.');
  }
}

if (!source.includes('Using GitHub Copilot?')) {
  const settingsNeedle = 'z.default.createElement("button",{style:{...p.button,...p.secondaryButton},onClick:c},"\\\\u2699\\\\uFE0F Open RunQL Settings"),z.default.createElement("button",{style:{...p.button,...p.secondaryButton},onClick:f},"\\\\u{1F4D8} Open README_RUNQL.md")';
  const settingsReplacement = `z.default.createElement("button",{style:{...p.button,...p.secondaryButton},onClick:c},"\\\\u2699\\\\uFE0F Open RunQL Settings"),z.default.createElement("div",{style:{fontSize:"13px",color:"var(--vscode-descriptionForeground)",marginTop:"4px",marginBottom:"8px"}},"Using GitHub Copilot? See ",z.default.createElement("a",{style:{...p.link,display:"inline",padding:0},href:"${guideUrl}",target:"_blank"},"GitHub Copilot in RunQL"),"."),z.default.createElement("button",{style:{...p.button,...p.secondaryButton},onClick:f},"\\\\u{1F4D8} Open README_RUNQL.md")`;
  if (source.includes(settingsNeedle)) {
    source = source.replace(settingsNeedle, settingsReplacement);
  } else {
    console.warn('RunQL welcome settings guide insertion point not found; skipping Copilot settings note.');
  }
}

fs.writeFileSync(file, source);
NODE
}

import_target() {
  local quality="$1"
  local dest="${ROOT_DIR}/src/${quality}/extensions/runql-client"

  rm -rf "${dest}"
  mkdir -p "${dest}"
  cp -R "${TMP_DIR}/extension/." "${dest}/"
  patch_manifest "${dest}/package.json"
  patch_welcome_app "${dest}"

  echo "Imported RunQL client into src/${quality}/extensions/runql-client"
}

if [[ "${TARGET}" == "stable" || "${TARGET}" == "both" ]]; then
  import_target stable
fi

if [[ "${TARGET}" == "insider" || "${TARGET}" == "both" ]]; then
  import_target insider
fi
