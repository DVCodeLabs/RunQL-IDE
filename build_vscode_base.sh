#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  echo "MS_COMMIT=\"${MS_COMMIT}\""

  . prepare_vscode.sh

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  export NODE_OPTIONS="--max-old-space-size=8192"

  npm run monaco-compile-check
  npm run valid-layers-check

  npm run gulp compile-build-without-mangling
  npm run gulp compile-extension-media
  npm run gulp compile-extensions-build
  npm run gulp minify-vscode

  cd ..
fi
