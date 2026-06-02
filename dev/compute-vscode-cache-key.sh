#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${VSCODE_QUALITY:-}" || -z "${OS_NAME:-}" || -z "${VSCODE_ARCH:-}" || -z "${MS_COMMIT:-}" ]]; then
  echo "Missing VSCODE_QUALITY, OS_NAME, VSCODE_ARCH, or MS_COMMIT" >&2
  exit 1
fi

IDE_COMMIT="${GITHUB_SHA:-$(git rev-parse HEAD)}"
BASE_VSCODE_CACHE_KEY="vscode-base-${VSCODE_QUALITY}-${OS_NAME}-${VSCODE_ARCH}-${MS_COMMIT}-${IDE_COMMIT}"

echo "BASE_VSCODE_CACHE_KEY=${BASE_VSCODE_CACHE_KEY}"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "BASE_VSCODE_CACHE_KEY=${BASE_VSCODE_CACHE_KEY}" >> "${GITHUB_ENV}"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "key=${BASE_VSCODE_CACHE_KEY}" >> "${GITHUB_OUTPUT}"
fi
