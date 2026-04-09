#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <stable|insider|both> [extension-dir-name]" >&2
  exit 1
fi

TARGET="$1"
EXTENSION_DIR_NAME="${2:-runql-client}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${TARGET}" in
  stable|insider|both)
    ;;
  *)
    echo "Invalid target: ${TARGET}" >&2
    exit 1
    ;;
esac

prepare_target() {
  local quality="$1"
  local extension_dir="${ROOT_DIR}/src/${quality}/extensions/${EXTENSION_DIR_NAME}"

  if [[ ! -f "${extension_dir}/package.json" ]]; then
    echo "Missing package.json in ${extension_dir}" >&2
    exit 1
  fi

  rm -rf "${extension_dir}/node_modules"
  (
    cd "${extension_dir}"
    npm install --omit=dev
  )
}

if [[ "${TARGET}" == "stable" || "${TARGET}" == "both" ]]; then
  prepare_target stable
fi

if [[ "${TARGET}" == "insider" || "${TARGET}" == "both" ]]; then
  prepare_target insider
fi
